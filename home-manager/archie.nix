{ config, pkgs, lib, ... }:

{

  home.file.".background-image" = {
    enable = true;
    source = ../programs/desktop/.background-image;
  };

  home.username = "isa";
  home.homeDirectory = "/home/isa";
  home.stateVersion = "25.11";
}
