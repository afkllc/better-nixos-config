{ config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name  = "afkllc";
      user.email = "22saqlaini@utcsheffield.org.uk";
      push.autoSetupRemote = true;
      gitCredentialHelper = {
        enable = true;
      };
    };
  };
}
