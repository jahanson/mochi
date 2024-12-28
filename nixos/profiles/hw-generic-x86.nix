{ lib, pkgs, ... }:
with lib;
{
  boot = {

    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    # for managing/mounting nfs
    supportedFilesystems = [ "nfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.memtest86.enable = true;

    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
