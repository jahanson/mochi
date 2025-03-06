{...}: {
  config = {
    networking.hostId = "ad4380db";
    networking.hostName = "durincore";
    # Kernel mods
    boot = {
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "nvme"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = [];
      };
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };

    fileSystems = {
      "/" = {
        device = "rpool/root";
        fsType = "zfs";
      };

      "/home" = {
        device = "rpool/home";
        fsType = "zfs";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/F1B9-CA7C";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
    };

    swapDevices = [];

    # System settings and services.
    mySystem = {
      system.motd.networkInterfaces = [
        "enp0s31f6"
        "wlp4s0"
      ];
    };
  };
}
