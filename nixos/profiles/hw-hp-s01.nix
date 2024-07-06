{ lib, pkgs, ... }:
{
  # Support windows partition
  mySystem = {
    security.wheelNeedsSudoPassword = false;
  };

  boot = {
    loader = {
      grub = {
        enable = true;
        zfsSupport = true;
        device = "nodev";
        mirroredBoots = [
          { devices = [ "nodev" ]; path = "/boot"; }
        ];
      };
    };
  };

  networking = {
    useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
