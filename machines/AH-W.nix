{ pkgs, lib, self, ... }:
{
  imports = [
    ./archie.nix
    ../programs/discord.nix
    ../programs/webots.nix
  ];

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#ah-w";


  boot.kernelModules = [ "sg" ];

  networking.hostName = "AH-W";
}
