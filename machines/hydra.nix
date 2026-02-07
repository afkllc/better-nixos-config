{ pkgs, lib, ... }:
{
  imports = [ ../hardware/generic.nix ];

  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:3000";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  environment.systemPackages = with pkgs; [ git ];

  system.stateVersion = "26.05";

  systemd.services.issue-ip = {
    description = "Generate /etc/issue with IP info";
    wantedBy = [ "multi-user.target" ];
    before = [ "getty@tty1.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "issue-ip" ''
        ${pkgs.iproute2}/bin/ip a > /run/issue
      '';
    };
  };

  nix = {
    buildMachines = [
      {
        hostName = "127.0.0.5";
        protocol = "ssh";
        sshUser = "hydra";
        sshKey = "/var/lib/hydra/.ssh/id_ed25519";
        system = "x86_64-linux";
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
        maxJobs = 1;
      }
      {
        hostName = "127.0.0.6";
        protocol = "ssh";
        sshUser = "hydra";
        sshKey = "/var/lib/hydra/.ssh/id_ed25519";
        system = "aarch64-linux";
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
        maxJobs = 1;
      }
    ];
    settings = {
      extra-experimental-features = "nix-command flakes";
    };
  };

  system.activationScripts.hydraSSHKey = {
    deps = [ "users" ];
    text = ''
      set -e

      keydir=/var/lib/hydra/.ssh
      keyfile=$keydir/id_ed25519

      if [ ! -f "$keyfile" ]; then
        echo "Generating Hydra SSH key…"
        mkdir -p "$keydir"
        chmod 700 "$keydir"

        ${pkgs.openssh}/bin/ssh-keygen \
          -t ed25519 \
          -N "" \
          -f "$keyfile"

        chmod 600 "$keyfile"
        chmod 644 "$keyfile.pub"
        chown -R hydra:hydra /var/lib/hydra/.ssh
      fi
    '';
  };

  system.activationScripts.hydraAuthorizedKey = {
    deps = [ "hydraSSHKey" ];
    text = ''
      set -e

      ak=/var/lib/hydra/.ssh/authorized_keys
      pub=/var/lib/hydra/.ssh/id_ed25519.pub

      if [ -f "$pub" ]; then
        mkdir -p "$(dirname "$ak")"
        touch "$ak"

        if ! grep -qxF "$(cat "$pub")" "$ak"; then
          cat "$pub" >> "$ak"
        fi

        chmod 600 "$ak"
        chown hydra:hydra "$ak"
      fi
    '';
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.root.initialPassword = "";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 5000 ];

  virtualisation.docker.enable = true;

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#hydra";

  networking.hostName = "hydra";
}
