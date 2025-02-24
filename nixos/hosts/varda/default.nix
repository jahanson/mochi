{
  pkgs,
  config,
  ...
}: {
  imports = [./resources/prune-backup.nix];

  networking.hostId = "cdab8473";
  networking.hostName = "varda"; # Define your hostname.

  # Add required CIFS support
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

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
      device = "/dev/disk/by-uuid/8091-E7F2";
      fsType = "vfat";
    };

    "/mnt/storagebox" = {
      device = "//u370253-sub2.your-storagebox.de/u370253-sub2";
      fsType = "cifs";

      options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,vers=3";
      in [
        "${automount_opts},credentials=${config.sops.secrets.sambaCredentials.path},uid=994,gid=993" # evaluated and deployed from another machine
      ];
    };
  };

  swapDevices = [];

  # sops
  sops = {
    secrets = {
      "sambaCredentials" = {
        sopsFile = ./secrets.sops.yaml;
      };
    };
  };

  services = {
    zfs = {
      expandOnBoot = "all";
      autoScrub.enable = true;
      trim.enable = true;
    };
  };

  # System settings and services.
  mySystem = {
    purpose = "Production";
    system.motd.networkInterfaces = ["enp1s0"];
    security.acme.enable = true;
    services = {
      forgejo = {
        enable = true;
        package = pkgs.unstable.forgejo;
      };
      nginx.enable = true;
    };
  };
}
