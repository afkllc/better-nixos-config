{ pkgs, lib, ... }:
{
  imports = [ ../hardware/generic.nix ];
  services.hydra = {
    enable = true;
    hydraURL = "http://localhost:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  nix.settings.extra-experimental-features = "nix-command flakes";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.root.initialPassword = "";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  virtualisation.docker.enable = true;

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#hydra";

  networking.hostName = "hydra";
}
