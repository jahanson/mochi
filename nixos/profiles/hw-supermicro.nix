{ lib, pkgs, ... }:
{
  boot = {
    # for managing/mounting nfs
    supportedFilesystems = [ "nfs" ];

    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = {
    networkmanager.enable = true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
