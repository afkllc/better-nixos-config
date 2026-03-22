{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    kwalletmanager
    kdeApplications.kwallet
    libsecret
  ];

  security.pam.services.login.enable = true;
  security.pam.services.sudo.enable = true;

  services.xserver = {
    enable = true;

    xkb = {
      layout = "gb";
      variant = "";
    };

    desktopManager = {
      xterm.enable = false;
      #xfce = {
      #  enable = true;
      #  noDesktop = true;
      #  enableXfwm = false;
      #};
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher most people use
        i3lock # default i3 screen locker
        i3blocks # if you are planning on using i3blocks over i3status
        rofi
      ];
      extraSessionCommands = ''
        /run/current-system/sw/bin/kwalletd5 &
      '';
    };
  };
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "none+i3";
}