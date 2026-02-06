{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    cachix
  ];
  nix = {
    settings = {
      substituters = [
        "https://nix-cache.archiesbytes.xyz"
      ];
      trusted-public-keys = [
        "nix-cache.archiesbytes.xyz:1TTuu9TNSBMvC1EspXSnT2kg1Y04TwvfsfmmnJLhWmU="
      ];
    };
  };
}