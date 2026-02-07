{ config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name  = "iLikeToCode";
      user.email = "archie@archiesbytes.xyz";
    };
  };
}
