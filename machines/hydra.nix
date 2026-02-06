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
      { hostName = "localhost";
        protocol = null;
        system = "aarch64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 1;
      }
    ];
    settings = {
      extra-experimental-features = "nix-command flakes";
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.root.initialPassword = "";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 5000 ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  virtualisation.docker.enable = true;

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#hydra";

  networking.hostName = "hydra";
}
