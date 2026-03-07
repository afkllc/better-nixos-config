{ pkgs, ... }:

{
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  networking.resolvconf.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";

  # Systemd service that creates br0 and enslaves all physical Ethernet devices
  systemd.services.dynamic-bridge = {
    description = "Create br0 bridge and enslave all Ethernet devices";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    # Make sure nmcli is in PATH
    path = with pkgs; [ networkmanager ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = "${pkgs.writeShellScript "dynamic-bridge.sh" ''
        #!/bin/sh
        set -e

        BRIDGE=br0

        # Create the bridge if it doesn't exist
        if ! nmcli connection show "$BRIDGE" >/dev/null 2>&1; then
          nmcli connection add type bridge con-name "$BRIDGE" ifname "$BRIDGE" ipv4.method auto ipv6.method auto
        fi

        # Loop over all physical Ethernet devices
        for dev in $(nmcli -t -f DEVICE,TYPE device | grep ethernet | cut -d: -f1); do
          # Remove any IP addresses and bring interface down
          ip addr flush dev "$dev" || true
          nmcli device set "$dev" managed yes
          nmcli device disconnect "$dev" || true

          # Add as bridge slave (ignore if already exists)
          nmcli connection add type bridge-slave ifname "$dev" master "$BRIDGE" || true
        done

        # Bring the bridge up
        nmcli connection up "$BRIDGE"
      ''}";
    };
  };
}