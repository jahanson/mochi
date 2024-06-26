{ config, lib, pkgs, ... }:
{
  # Support windows partition
  mySystem.system.packages = with pkgs; [
    ntfs3g
    fira-code-nerdfont
  ];

  security.wheelNeedsSudoPassword = false;

  boot = {
    # for managing/mounting ntfs
    supportedFilesystems = [ "ntfs" ];

    # Use the systemd-boot EFI boot loader.
    loader = {
      grub = {
        enable = true;
        useOSProber = true;
        zfsSupport = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        mirroredBoots = [
          { devices = ["nodev"]; path = "/boot";}
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
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
