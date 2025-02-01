{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  sanoidConfig = import ./config/sanoid.nix {};
  disks = import ./config/disks.nix;
  smartdDevices = map (device: {inherit device;}) disks;
in {
  imports = [
    inputs.disko.nixosModules.disko
    (import ../../profiles/disko-nixos.nix {
      disks = ["/dev/sda|/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S58SNM0W406409E"];
    })
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  boot = {
    initrd = {
      kernelModules = ["nfs"];
      supportedFilesystems = ["nfs"];
    };

    binfmt.emulatedSystems = ["aarch64-linux"]; # Enabled for arm compilation

    kernelModules = [
      "vfio"
      "vfio_iommu_type1"
      "vfio_pci"
      "vfio_virqfd"
    ];
    extraModulePackages = [];
    kernelParams = ["zfs.zfs_arc_max=107374182400"]; # 100GB
  };

  swapDevices = [];

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    nvidia.open = true;
    graphics.enable = true;
    # opengl.enable = true;
    nvidia-container-toolkit.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [];

  # Network settings
  networking = {
    hostName = "shadowfax";
    hostId = "a885fabe";
  };

  # Home Manager
  home-manager.users.jahanson = {
    # Git settings
    # TODO: Move to config module.
    programs.git = {
      enable = true;
      userName = "Joseph Hanson";
      userEmail = "joe@veri.dev";

      extraConfig = {
        core.autocrlf = "input";
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    libva-utils # to view graphics capabilities
    greetd.tuigreet
    rofi-wayland
    grim
    inxi
    nvtopPackages.full
    pyprland
    swaynotificationcenter
    swww
    wallust
    wl-clipboard
    wlogout
    # fun
    fastfetch
  ];
  programs = {
    # 1Password cli
    _1password.enable = true;

    # Mosh
    mosh.enable = true;

    # VSCode Compatibility Settings
    nix-ld.enable = true;

    # Hyprland
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      withUWSM = true;
      # xwayland.enable = true;
    };
    waybar.enable = true;
    thunar.enable = true;
    thunar.plugins = with pkgs.xfce; [
      exo
      mousepad
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      # Caddy
      80 # http
      443 # https
      2019 # caddy admin api
      # Minio
      9000 # console web interface
      9001 # api interface
    ];
  };

  services = {
    # Minio
    minio = {
      enable = true;
      dataDir = ["/eru/minio"];
      rootCredentialsFile = config.sops.secrets."minio".path;
    };

    # Netdata
    netdata = {
      enable = true;
    };

    # Prometheus exporters
    prometheus.exporters = {
      # Node Exporter - port 9100
      node.enable = true;
      # ZFS Exporter - port 9134
      zfs.enable = true;
    };

    # Smart daemon for monitoring disk health.
    smartd = {
      devices = smartdDevices;
      # Short test every day at 2:00 AM and long test every Sunday at 4:00 AM.
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";
    };

    # Soft Serve - SSH git server
    soft-serve = {
      enable = true;
      settings = import ./config/soft-serve.nix {};
    };

    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # only needed for Wayland
      openFirewall = true;
      package = pkgs.unstable.sunshine;
    };

    # Tailscale
    tailscale = {
      enable = true;
      openFirewall = true;
    };

    # VSCode Compatibility Settings
    vscode-server.enable = true;

    xserver.videoDrivers = ["nvidia"];
    greetd = {
      enable = true;
      vt = 3;
      settings = {
        default_session = {
          user = "jahanson";
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
        };
      };
    };
  };

  # sops
  sops.secrets = {
    "minio" = {
      sopsFile = ./secrets.sops.yaml;
      owner = "minio";
      group = "minio";
      mode = "400";
      restartUnits = ["minio.service"];
    };
    "syncthing/publicCert" = {
      sopsFile = ./secrets.sops.yaml;
      owner = "jahanson";
      mode = "400";
      restartUnits = ["syncthing.service"];
    };
    "syncthing/privateKey" = {
      sopsFile = ./secrets.sops.yaml;
      owner = "jahanson";
      mode = "400";
      restartUnits = ["syncthing.service"];
    };
  };

  # System settings and services.
  mySystem = {
    # VS Code
    editor.vscode.enable = true;
    # Containers
    containers = {
      jellyfin.enable = true;
      ollama.enable = true;
      plex.enable = true;
      scrypted.enable = true;
    };
    purpose = "Production";
    # Services
    services = {
      # Misc
      libvirt-qemu.enable = true;
      podman.enable = true;
      # Prowlarr
      prowlarr = {
        enable = true;
        package = pkgs.unstable.prowlarr;
        dataDir = "/nahar/prowlarr";
        hardening = true;
        openFirewall = true;
        port = 9696;
      };
      # Sabnzbd
      sabnzbd = {
        enable = true;
        package = pkgs.unstable.sabnzbd;
        configFile = "/nahar/sabnzbd/sabnzbd.ini";
        port = 8457;
        # Security hardening.
        dataDir = "/nahar/sabnzbd";
        downloadsDir = "/eru/media/sabnzbd";
        hardening = true;
        openFirewall = true;
      };
      # Sanoid
      sanoid = {
        enable = true;
        inherit (sanoidConfig.outputs) templates datasets;
      };
      # Scrutiny
      scrutiny = {
        enable = true;
        devices = disks;
        extraCapabilities = [
          "SYS_RAWIO"
          "SYS_ADMIN"
        ];
        containerVolumeLocation = "/nahar/containers/volumes/scrutiny";
        port = 8585;
      };
      # Syncthing
      syncthing = {
        enable = false;
        user = "jahanson";
        publicCertPath = config.sops.secrets."syncthing/publicCert".path;
        privateKeyPath = config.sops.secrets."syncthing/privateKey".path;
      };
      # qBittorrent
      qbittorrent = {
        enable = true;
        package = pkgs.unstable.qbittorrent.override {guiSupport = false;};
        dataDir = "/nahar/qbittorrent";
        downloadsDir = "/eru/media/qb/downloads";
        webuiPort = 8456;
        openFirewall = true;
        hardening = true;
        qbittorrentPort = 50413;
      };
      # ZFS nightly snapshot of container volumes
      zfs-nightly-snap = {
        enable = true;
        mountPath = "/mnt/restic_nightly_backup";
        zfsDataset = "nahar/containers/volumes";
        snapshotName = "restic_nightly_snap";
        startAt = "*-*-* 06:30:00 America/Chicago";
      };
    };
    # System
    system = {
      incus = {
        enable = true;
        preseed = import ./config/incus-preseed.nix {};
      };
      motd.networkInterfaces = ["bond0"];
      nfs.enable = true;
      zfs.enable = true;
      zfs.mountPoolsAtBoot = [
        "eru"
        "moria"
        "nahar"
      ];
    };
  };
}
