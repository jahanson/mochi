{ lib, pkgs, ... }:
with lib;
{
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
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
