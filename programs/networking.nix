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

        # Create bridge br0 if it doesn't exist
        if ! nmcli connection show br0 >/dev/null 2>&1; then
          nmcli connection add type bridge con-name br0 ifname br0 ipv4.method auto ipv6.method auto
        fi

        # Loop over all physical Ethernet devices and enslave them to br0
        for dev in $(nmcli -t -f DEVICE,TYPE device | grep ethernet | cut -d: -f1); do
          nmcli connection add type bridge-slave ifname "$dev" master br0 || true
        done

        # Bring the bridge up
        nmcli connection up br0
      ''}";
      RemainAfterExit = true;
    };
  };
}