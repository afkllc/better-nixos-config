{ pkgs, lib, self, ... }:
{
  imports = [
    ./archie.nix
    ../programs/discord.nix
  ];

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024;
  }];

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#ah-w";

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  environment.systemPackages = with pkgs; [
    self.packages.x86_64-linux.webots
    openscad
  ];

  boot.kernelModules = [ "sg" ];

  networking.hostName = "AH-W";
}
