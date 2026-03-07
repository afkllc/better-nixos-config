{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        qemu_full
    ];
    programs.virt-manager.enable = true;

    networking.nftables.enable = true;
    networking.firewall.trustedInterfaces = [ "docker0" ];

    virtualisation = {
        libvirtd = {
            enable = true;
            allowedBridges = [ "docker0" ];
            qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
        };
        spiceUSBRedirection.enable = true;
        docker.enable = true;
    };
}
