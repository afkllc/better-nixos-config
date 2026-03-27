{ pkgs, lib, self, ... }:
{
  imports = [
    ./archie.nix
  ];

  networking.nat.enable = true;
  networking.nat.externalInterface = "enp5s0";

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/afkllc/better-nixos-config#ah-w";

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "i3";
  services.openssh.enable = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  environment.systemPackages = with pkgs; [
    #self.packages.x86_64-linux.webots
    openscad
  ];

  boot.kernelModules = [ "sg" ];

  networking.hostName = "AH-W";
}
