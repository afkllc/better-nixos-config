{ pkgs, ... }:

let
  dynamicBridgeScript = pkgs.writeBinScript "dynamic-bridge" ''
    #!/bin/sh
    set -e

    # Loop over all physical Ethernet devices and enslave them to br0
    for dev in $(nmcli -t -f DEVICE,TYPE device | grep ethernet | cut -d: -f1); do
      nmcli connection add type bridge-slave ifname "$dev" master br0 || true
    done

    # Bring the bridge up
    nmcli connection up br0
  '';
in
{
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  networking.resolvconf.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";

  networking.bridges.br0 = {};

  systemd.services.dynamic-bridge = {
    description = "Enslave all Ethernet devices to br0";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dynamicBridgeScript}";
      RemainAfterExit = true;
    };
  };
}
