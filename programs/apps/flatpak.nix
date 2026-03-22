{ pkgs, ... }:

{
    services.flatpak.enable = true;

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

        config = {
            common = {
                default = [ "*" ];
            };
        };
    };

    system.activationScripts.flatpakFlathub = {
    text = ''
        ${pkgs.flatpak}/bin/flatpak \
        remote-add --if-not-exists \
        flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
    };
}