{ config, pkgs, lib, ... }:

let
  channel-name = "nixos-unstable";
  nix-channel-watcher = pkgs.fetchFromGitHub {
    owner = "InternetUnexplorer";
    repo = "nix-channel-watcher";
    rev = "9439dc8f23f2ddb8bba009d4d3c78097d34edd9e";
    sha256 = "0p04wy7rl96r9mz6wx61557849jvy6kil2drf8z4d68hkcxwhm11";
  };
in {
  systemd.user.services.nix-channel-watcher = {
    Unit.Description = "check Nix channels for updates";
    Service = {
      Type = "oneshot";
      WorkingDirectory = "${config.xdg.dataHome}/nix-channel-watcher";
      ExecStart = "${nix-channel-watcher}/channel-watcher.py";
      TimeoutSec = 30;
    };
  };

  systemd.user.timers.nix-channel-watcher = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "*:0/5";
  };

  home.file."${config.xdg.dataHome}/nix-channel-watcher/channels.txt".text = ''
    nixos-unstable https://nixos.org/channels/nixos-unstable 0
  '';

  xdg.dataFile."nix-channel-watcher/${channel-name}.hooks/send-notification".source =
    pkgs.writeScript "send-notification" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.libnotify}/bin/notify-send  \
        --expire-time 0                  \
        --icon software-update-available \
        --app-name "Nix Channel Watcher" \
        "A Nix channel was updated!"     \
        "$1@''${3:0:10}"
    '';
}