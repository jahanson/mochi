{ ... }: {
  config = {

    # hardware-configuration.nix - half of the hardware-configuration.nix file

    networking.hostId = "ad4380db";
    networking.hostName = "durincore";

    fileSystems."/" =
      { device = "rpool/root";
        fsType = "zfs";
      };

    fileSystems."/home" =
      { device = "rpool/home";
        fsType = "zfs";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/F1B9-CA7C";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices = [ ];

    # System settings and services.
    mySystem = {
      system.motd.networkInterfaces = [ "enp0s31f6" "wlp4s0" ];
    };

  };
}
