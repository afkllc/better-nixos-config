{ lib, ... }:
{
  imports = [
    ./archie.nix
    ../programs/discord.nix
  ];

  hardware.enableRedistributableFirmware = true;

  boot.kernelParams = [
    "acpi_enforce_resources=lax"
    "i915.enable_dc=0"

    "pcie_aspm=off"
  ];

  boot.extraModprobeConfig = ''
    options snd-hda-intel model=mute-led-gpio

    options iwlwifi power_save=0
    options iwlwifi uapsd_disable=1
  '';

  system.autoUpgrade.flake = lib.mkForce "git+https://github.com/iLikeToCode/nixos-config#ah-l";

  networking.hostName = "AH-L";
}
