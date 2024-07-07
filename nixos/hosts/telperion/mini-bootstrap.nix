# This is a small config that can be used to bootstrap a system with ZFS.
{ config, lib, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  networking.hostId = "ce196a02";
  networking.hostName = "telperion";
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
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

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zroot/nix";
    fsType = "zfs";
  };

  fileSystems."/var" = {
    device = "zroot/var";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zroot/home";
    fsType = "zfs";
  };

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  system.stateVersion = "24.05";
}
