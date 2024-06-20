{ ... }: {
  imports = [ ];

  networking.hostId = "cdab8473";
  networking.hostName = "varda"; # Define your hostname.

  fileSystems."/" = {
    device = "rpool/root";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8091-E7F2";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # System settings and services.
  mySystem = {
    system.motd.networkInterfaces = [ "enp1s0" ];
    security.acme.enable = true;
    services = {
      forgejo.enable = true;
      nginx.enable = true;
    };
  };

}
