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
      { hostName = "127.0.0.7";
        protocol = null;
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 1;
      }
      { hostName = "127.0.0.8";
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

  environment.etc."ssh/sshd_config_127_7" = {
    text = ''
      Port 22
      ListenAddress 127.0.0.7
      HostKey /etc/ssh/ssh_host_rsa_127_7
      PidFile /run/sshd_127_7.pid
      # other defaults you want
      PermitRootLogin no
      PasswordAuthentication yes
    '';
    mode = "0644";
  };

  environment.etc."ssh/sshd_config_127_8" = {
    text = ''
      Port 22
      ListenAddress 127.0.0.8
      HostKey /etc/ssh/ssh_host_rsa_127_8
      PidFile /run/sshd_127_8.pid
      PermitRootLogin no
      PasswordAuthentication yes
    '';
    mode = "0644";
  };

  systemd.services.ssh-extra-key-127-7 = {
    description = "Generate SSH host key for 127.0.0.7";
    wantedBy = [ "multi-user.target" ];
  
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "ssh-extra-key-127-7" ''
        keyfile="/etc/ssh/ssh_host_rsa_127_7"
        if [ ! -f "$keyfile" ]; then
          echo "Generating host key for 127.0.0.7..."
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -f "$keyfile" -N "" >/dev/null
        fi
      '';
    };
  };

  systemd.services.ssh-extra-key-127-8 = {
    description = "Generate SSH host key for 127.0.0.8";
    wantedBy = [ "multi-user.target" ];
  
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "ssh-extra-key-127-8" ''
        keyfile="/etc/ssh/ssh_host_rsa_127_8"
        if [ ! -f "$keyfile" ]; then
          echo "Generating host key for 127.0.0.8..."
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -f "$keyfile" -N "" >/dev/null
        fi
      '';
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.root.initialPassword = "";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 5000 ];

  systemd.services.sshd1277 = {
    enable = true;
    description = "OpenSSH Server on 127.0.0.7";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/sshd -D -f /etc/ssh/sshd_config_127_7";
      Restart = "always";
    };
  };
  
  systemd.services.sshd1278 = {
    enable = true;
    description = "OpenSSH Server on 127.0.0.8";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/sshd -D -f /etc/ssh/sshd_config_127_8";
      Restart = "always";
    };
  };

  virtualisation.docker.enable = true;

  users.groups.sshd = {};

  users.users.sshd = {
    group = "sshd";
    description = "SSH daemon user";
    isSystemUser = true;
    createHome = false;
    shell = pkgs.bash;
  };

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#hydra";

  networking.hostName = "hydra";
}
