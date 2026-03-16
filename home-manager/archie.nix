{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./nix-channel-watcher.nix
  ];

  home.username = "archie";
  home.homeDirectory = "/home/archie";
  home.stateVersion = "25.11";
}
