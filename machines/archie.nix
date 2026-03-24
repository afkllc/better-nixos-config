{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ../hardware/generic.nix
    ../programs/apps/firefox.nix
    ../programs/apps/vscode.nix
    ../programs/apps/python.nix
    ../programs/git.nix
    ../programs/zsh.nix
    ../programs/virtualisation.nix
    ../programs/apps/node.nix
    ../programs/networking.nix
    ../programs/apps/flatpak.nix
    #../programs/cachix.nix
  ];

  services.logind.settings.Login.HandlePowerKey = "hibernate";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.registrations."aarch64-linux".fixBinary = true;

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024;
  }];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  fileSystems."/home/archie/share" = {
    device = "//132.145.48.53/archie";
    fsType = "cifs";

    options = [
      "_netdev"
      "credentials=/etc/samba/media.creds"
      "iocharset=utf8"
      "uid=1000"
      "gid=1000"
      "vers=3.1.1"
      "nofail"
      "x-systemd.automount"
    ];
  };


  system.autoUpgrade = {
    enable = true;
    flake = self.outPath;
    dates = "03:00";
  };

  programs.nh = {
    enable = true;

    clean = {
      enable = true;
      extraArgs = "--keep 5";
    };
  };

  users.users.archie = {
    description = "Archie Hurst";
    isNormalUser = true;
    extraGroups = [ "dialout" "networkmanager" "wheel" ];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "archie" ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "uk";
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    bitwarden-desktop
    protonvpn-gui
    freeplane
    libreoffice
    blender
    element-desktop
    vlc
    wine64Packages.full
    cifs-utils
    rustup
    rust-analyzer
    mongodb-compass
    slack
    slack-term
    trayscale
    btop
  ];

  system.stateVersion = "26.05";
}
