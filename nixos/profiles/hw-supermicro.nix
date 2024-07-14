{ lib, pkgs, ... }:
{
  boot = {
    # for managing/mounting nfs
    supportedFilesystems = [ "nfs" ];

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        mirroredBoots = [
          { devices = [ "nodev" ]; path = "/boot"; }
        ];
      };
    };
  };

  networking = {
    networkmanager.enable = true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
