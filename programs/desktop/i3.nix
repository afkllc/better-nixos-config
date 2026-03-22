{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    acpi
    pulseaudio
    kitty
    feh
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;  # provides pactl compatibility
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

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
    };
  };
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "none+i3";
}
