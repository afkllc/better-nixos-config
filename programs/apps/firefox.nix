{ config, pkgs, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  programs.firefox = {
    enable = true;
    languagePacks = [ "en-GB" ];
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "always";
      DisplayMenuBar = "default-off";
      SearchBar = "unified";
      ExtensionSettings = {
        "*".installation_mode = "blocked";

        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
      };
      ExtensionPolicies = {
        bitwarden = {
          server_url = {
            Value = "https://vaultwarden.archiesbytes.xyz";
            Status = "locked";
          };

          cloud_region = {
            Value = "self-hosted";
            Status = "locked";
          };

          disable_auto_biometrics = {
            Value = true;
            Status = "locked";
          };

          lock_timeout = {
            Value = 5;
            Status = "locked";
          };

          lock_timeout_action = {
            Value = "lock";
            Status = "locked";
          };

          disable_account_switch = {
            Value = true;
            Status = "locked";
          };
        };
      };
    };
    preferences = {
      "extensions.pocket.enabled" = false;
    };
  };
}