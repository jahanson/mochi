{ lib, pkgs, ... }:
{
  # Support windows partition
  mySystem = {
    security.wheelNeedsSudoPassword = false;
    system.packages = with pkgs; [
      ntfs3g
    ];
  };

  boot = {
    # for managing/mounting ntfs
    supportedFilesystems = [ "ntfs" "nfs" ];

    loader = {
      grub = {
        enable = true;
        zfsSupport = true;
        device = "nodev";
        mirroredBoots = [
          { devices = [ "nodev" ]; path = "/boot"; }
        ];
      };
      # efi = {
      #   canTouchEfiVariables = true;
      # };
    };
  };

  networking = {
    useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
