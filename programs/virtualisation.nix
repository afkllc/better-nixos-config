{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        qemu
    ];
    programs.virt-manager.enable = true;

    networking.nftables.enable = true;

    networking.bridges = {
        vmbr0.interfaces = [ ];
        vmbr1.interfaces = [ ];
    };

    networking.interfaces.vmbr0 = {
        ipv4.addresses = [{ address = "192.168.10.1"; prefixLength = 24; }];
    };

    networking.interfaces.vmbr1 = {
        ipv4.addresses = [{ address = "192.168.20.1"; prefixLength = 24; }];
    };

    services.dnsmasq = {
        enable = true;

        settings = {
            interface = [ "vmbr0" ];

            dhcp-range = [
                "vmbr0,192.168.10.10,192.168.10.200,12h"
                "vmbr1,192.168.20.10,192.168.20.200,12h"
            ];

            dhcp-option = [
                "interface:vmbr0,option:router,192.168.10.1"
                "interface:vmbr1,option:router"  # empty = no gateway
            ];
        };
    };

    networking.nat.enable = true;

    networking.firewall.trustedInterfaces = [ "vmbr0" ];

    networking.nat.internalInterfaces = [ "vmbr0" ];

    users.users.archie.extraGroups = [ "docker" "libvirt" ];

    virtualisation = {
        libvirtd = {
            enable = true;
            allowedBridges = [ "vmbr0" "vmbr1" ];
            qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
        };
        spiceUSBRedirection.enable = true;
        docker.enable = true;
    };
}
