{ pkgs, lib, self, ... }:
{
  imports = [
    ./archie.nix
    ../programs/discord.nix
  ];

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#ah-w";


  environment.systemPackages = [
    self.packages.x86_64-linux.webots
    openscad
  ];

  boot.kernelModules = [ "sg" ];

  networking.hostName = "AH-W";
}
