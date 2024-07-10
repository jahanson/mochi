{ lib, pkgs, ... }:
{
  # Support windows partition
  mySystem = {
    security.wheelNeedsSudoPassword = false;
  };

  boot = {
    # for managing/mounting ntfs
    supportedFilesystems = [ "nfs" ];

    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
