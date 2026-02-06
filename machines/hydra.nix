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
      { hostName = "127.0.0.5";
        protocol = null;
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 1;
      }
      { hostName = "127.0.0.6";
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

  environment.etc."ssh/sshd_config_127_5" = {
    text = ''
      Port 22
      ListenAddress 127.0.0.5
      HostKey /etc/ssh/ssh_host_rsa_127_5
      PidFile /run/sshd_127_5.pid
      # other defaults you want
      PermitRootLogin no
      PasswordAuthentication yes
    '';
    mode = "0644";
  };

  environment.etc."ssh/sshd_config_127_6" = {
    text = ''
      Port 22
      ListenAddress 127.0.0.6
      HostKey /etc/ssh/ssh_host_rsa_127_6
      PidFile /run/sshd_127_6.pid
      PermitRootLogin no
      PasswordAuthentication yes
    '';
    mode = "0644";
  };

  systemd.services.ssh-extra-key-127-5 = {
    description = "Generate SSH host key for 127.0.0.5";
    wantedBy = [ "multi-user.target" ];
    before = [ "getty@tty1.service" ];
  
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "ssh-extra-key-127-5" ''
        keyfile="/etc/ssh/ssh_host_rsa_127_5"
        if [ ! -f "$keyfile" ]; then
          echo "Generating host key for 127.0.0.5..."
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -f "$keyfile" -N "" >/dev/null
        fi
      '';
    };
  };

  systemd.services.ssh-extra-key-127-6 = {
    description = "Generate SSH host key for 127.0.0.6";
    wantedBy = [ "multi-user.target" ];
    before = [ "getty@tty1.service" ];
  
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "ssh-extra-key-127-6" ''
        keyfile="/etc/ssh/ssh_host_rsa_127_6"
        if [ ! -f "$keyfile" ]; then
          echo "Generating host key for 127.0.0.6..."
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

  systemd.services.sshd1275 = {
    enable = true;
    description = "OpenSSH Server on 127.0.0.5";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/sshd -D -f /etc/ssh/sshd_config_127_5";
      Restart = "always";
    };
  };
  
  systemd.services.sshd1276 = {
    enable = true;
    description = "OpenSSH Server on 127.0.0.6";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/sshd -D -f /etc/ssh/sshd_config_127_6";
      Restart = "always";
    };
  };

  virtualisation.docker.enable = true;

  users.users.sshd = {
    description = "SSH daemon user";
    systemUser = true;
    createHome = false;
    shell = pkgs.bash;
  };

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#hydra";

  networking.hostName = "hydra";
}
