{ config, pkgs, lib, ... }:

let
  checkScript = pkgs.writeShellScript "flake-nixpkgs-watcher" ''
    set -euo pipefail

    LOCKFILE=/etc/nixos/flake.lock

    # locked nixpkgs revision
    LOCKED_REV=$(jq -r '.nodes.nixpkgs.locked.rev' "$LOCKFILE")

    # upstream nixpkgs revision
    UPSTREAM_REV=$(nix flake metadata nixpkgs --json | jq -r '.revision')

    if [ "$LOCKED_REV" != "$UPSTREAM_REV" ]; then
      ${pkgs.libnotify}/bin/notify-send \
        --expire-time=0 \
        --icon=software-update-available \
        --app-name="Nix Flake Watcher" \
        "nixpkgs update available" \
        "locked: $LOCKED_REV → upstream: $UPSTREAM_REV"
    fi
  '';
in
{
  systemd.user.services.flake-nixpkgs-watcher = {
    Unit.Description = "Check flake nixpkgs input for updates";
    path = with pkgs; [ jq ];
    Service = {
      Type = "oneshot";
      ExecStart = checkScript;
      TimeoutSec = 30;
    };
  };

  systemd.user.timers.flake-nixpkgs-watcher = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "*:0/5";
  };
}