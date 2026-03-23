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
    xfce4-terminal
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
        i3lock-fancy
        i3blocks
        rofi
      ];
    };
  };
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "none+i3";
}
