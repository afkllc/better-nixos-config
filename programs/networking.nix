{ pkgs, ... }:

{
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  networking.resolvconf.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";

  systemd.services.dynamic-bridge = {
    description = "Create br0 bridge and enslave all Ethernet devices";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ networkmanager ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "dynamic-bridge.sh" ''
      #!/bin/sh
      set -e

      BRIDGE=br0

      # Create bridge if it doesn't exist
      if ! nmcli connection show "$BRIDGE" >/dev/null 2>&1; then
        nmcli connection add type bridge con-name "$BRIDGE" ifname "$BRIDGE" ipv4.method auto ipv6.method auto
      fi

      # Loop over all physical Ethernet devices
      for dev in $(nmcli -t -f DEVICE,TYPE device | grep ethernet | cut -d: -f1); do
        # Bring the interface down before enslaving
        nmcli device set "$dev" managed yes
        nmcli device disconnect "$dev" || true

        # Add as a bridge slave (ignore if already exists)
        nmcli connection add type bridge-slave ifname "$dev" master "$BRIDGE" || true
      done

      # Bring the bridge up
      nmcli connection up "$BRIDGE"
      ''}";
      RemainAfterExit = true;
    };
  };
}