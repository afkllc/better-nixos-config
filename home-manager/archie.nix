{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./nix-channel-watcher.nix
    ../programs/desktop/i3-config.nix
  ];

  home.file.".background-image" = {
    enable = true;
    source = ../programs/desktop/.background-image;
  };

  home.username = "archie";
  home.homeDirectory = "/home/archie";
  home.stateVersion = "25.11";
}
