{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.xserver = {
    xkb = {
      layout = "gb";
      variant = "";
    };
  };
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher most people use
        i3lock # default i3 screen locker
        i3blocks # if you are planning on using i3blocks over i3status
        rofi
      ];
    };
  };
  services.displayManager.defaultSession = "none+i3";
}