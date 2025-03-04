{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    # Enable bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  boot = {
    # for managing/mounting nfs
    supportedFilesystems = ["nfs"];

    # EFI, systemd-bootd instead of grub.
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };

    initrd.availableKernelModules = [
      "xhci_pci" # usb 3.0 and other pci devices
      "nvme" # nvme drives
      "usbhid" # usb keyboards and mice
      "usb_storage" # usb storage devices
      "sd_mod" # Storage devices
      "thunderbolt" # Thunderbolt devices
    ];

    initrd.kernelModules = ["amdgpu"]; # AMD GPU
    kernelModules = ["kvm-amd"]; # hardware assisted virtualization
    extraModulePackages = [];
  };
  mySystem = {
    security.wheelNeedsSudoPassword = false; # Allow wheel group to sudo without password
  };

  networking = {
    hostId = "4488bd1a"; # Unique identifier for the host, often for ZFS.
    hostName = "telchar";
  };

  # For updating firmware on the Framework.
  services.fwupd.enable = true;

  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
