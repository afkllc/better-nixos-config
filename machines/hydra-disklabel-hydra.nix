{ pkgs, ... }:
{
  imports = [ ./hydra.nix ];
  
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/hydra";
    fsType = "ext4";
    neededForBoot = true;
  };
}
