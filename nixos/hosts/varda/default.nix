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
    minio-client
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
      "security/acme/env" = {
        sopsFile = ./secrets.sops.yaml;
        restartUnits = ["lego.service"];
      };
    };
  };

  programs = {
    # Mosh
    mosh = {
      enable = true;
      openFirewall = true;
    };
  };

  services = {
    zfs = {
      # This helps a lot when upgrading
      expandOnBoot = "all";
      autoScrub.enable = true;
      trim.enable = true;
    };
  };

  # ACME (Let's Encrypt) Configuration
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@${config.networking.domain}";

    certs.${config.networking.domain} = {
      extraDomainNames = [
        "${config.networking.domain}"
        "*.${config.networking.domain}"
      ];
      dnsProvider = "dnsimple";
      dnsResolver = "1.1.1.1:53";
      credentialsFile = config.sops.secrets."security/acme/env".path;
    };
  };

  # System settings and services.
  mySystem = {
    purpose = "Production";
    system.motd.networkInterfaces = ["enp1s0"];
    services = {
      forgejo = {
        enable = true;
        package = pkgs.unstable.forgejo;
      };
      nginx.enable = true;
    };
  };
}
