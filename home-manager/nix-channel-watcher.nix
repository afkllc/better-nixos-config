{ config, pkgs, lib, ... }:

let
  checkScript = pkgs.writeShellScript "flake-nixpkgs-watcher" ''
    #!/usr/bin/env bash
    set -euo pipefail

    LOCKFILE=/etc/nixos/flake.lock

    OWNER=$(${pkgs.jq}/bin/jq -r '.nodes.nixpkgs.locked.owner' "$LOCKFILE")
    REPO=$(${pkgs.jq}/bin/jq -r '.nodes.nixpkgs.locked.repo' "$LOCKFILE")
    REF=$(${pkgs.jq}/bin/jq -r '.nodes.nixpkgs.locked.ref // "nixos-unstable"' "$LOCKFILE")
    LOCKED_REV=$(${pkgs.jq}/bin/jq -r '.nodes.nixpkgs.locked.rev' "$LOCKFILE")

    UPSTREAM_REV=$(nix flake metadata "github:$OWNER/$REPO/$REF" --json \
      | ${pkgs.jq}/bin/jq -r '.revision')

    if [ "$UPSTREAM_REV" != "null" ] && [ "$LOCKED_REV" != "$UPSTREAM_REV" ]; then
      ${pkgs.libnotify}/bin/notify-send \
        --expire-time=0 \
        --app-name="Nix Flake Watcher" \
        "nixpkgs update available" \
        "locked: $LOCKED_REV → upstream: $UPSTREAM_REV"
    fi
  '';
in
{
  systemd.user.services.flake-nixpkgs-watcher = {
    Unit.Description = "Check flake nixpkgs input for updates";
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