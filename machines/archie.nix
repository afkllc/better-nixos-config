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
    ../programs/desktop/kde.nix
    #../programs/cachix.nix
  ];

  services.logind.settings.Login.HandlePowerKey = "hibernate";

  swapDevices = [{
    device = "/swapfile";
    size = 8 * 1024;
  }];


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

  users.users.isa = {
    description = "isa";
    isNormalUser = true;
    extraGroups = [ "dialout" "networkmanager" "wheel" ];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "isa" ];

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
    blender
    btop
  ];

  system.stateVersion = "26.05";
}
