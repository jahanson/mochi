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
  pushoverNotify = pkgs.writeShellApplication {
    name = "pushover-notify";

    runtimeInputs = with pkgs; [
      curl
      jo
      jq
    ];

    excludeShellChecks = ["SC2154"];

    text = ''
      ${builtins.readFile ./scripts/pushover-notify.sh}
    '';
  };
  refreshSeries = pkgs.writeShellApplication {
    name = "refresh-series";

    runtimeInputs = with pkgs; [
      curl
      jq
    ];

    excludeShellChecks = ["SC2154"];

    text = ''
      ${builtins.readFile ./scripts/refresh-series.sh}
    '';
  };
in {
  imports = [
    inputs.disko.nixosModules.disko
    (import ../../profiles/disko-nixos.nix {
      disks = ["/dev/sda|/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S58SNM0W406409E"];
    })
    ./config/borgmatic
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

  # System packages
  environment.systemPackages = with pkgs; [
    # dev
    uv
    # fun
    fastfetch
    # Scripts
    pushoverNotify
    refreshSeries
  ];

  # enable docker socket at /run/docker.sock
  virtualisation.podman.dockerSocket.enable = true;

  programs = {
    # 1Password cli
    _1password.enable = true;
    _1password-gui.enable = true;

    # Mosh
    mosh.enable = true;

    # VSCode Compatibility Settings
    nix-ld.enable = true;
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      # Caddy
      80 # http
      443 # https
      179 # BGP
      2019 # caddy admin api
      # Minio
      9000 # console web interface
      9001 # api interface
      # Beszel-agent
      45876
      # scrypted
      45005
    ];
  };

  services = {
    # Minecraft
    minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      dataDir = "/nahar/minecraft";
      servers.fabric = {
        enable = true;

        # Specify the custom minecraft server package
        package = pkgs.fabricServers.fabric-1_21_1.override {
          loaderVersion = "0.16.10";
        }; # Specific fabric loader version

        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (
            builtins.attrValues {
              Fabric-API = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar";
                sha512 = "e5f3c3431b96b281300dd118ee523379ff6a774c0e864eab8d159af32e5425c915f8664b1cd576f20275e8baf995e016c5971fea7478c8cb0433a83663f2aea8";
              };
              Backpacks = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/MGcd6kTf/versions/Ci0F49X1/1.2.1-backpacks_mod-1.21.2-1.21.3.jar";
                sha512 = "6efcff5ded172d469ddf2bb16441b6c8de5337cc623b6cb579e975cf187af0b79291b91a37399a6e67da0758c0e0e2147281e7a19510f8f21fa6a9c14193a88b";
              };
            }
          );
        };
      };
    };
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
  };

  # sops
  sops = import ./config/sops-secrets.nix {};

  # System settings and services.
  mySystem = {
    ## Desktop Environment
    # Hyprland
    de.hyprland.enable = true;
    # VS Code
    editor.vscode.enable = true;
    # Containers
    containers = {
      jellyfin.enable = true;
      jellyseerr.enable = true;
      ollama.enable = true;
      plex.enable = true;
      scrypted.enable = true;
    };
    purpose = "Production";
    # Services
    services = {
      borgmatic.enable = true;
      # Misc
      libvirt-qemu.enable = true;
      podman.enable = true;
      # Prowlarr
      prowlarr = {
        enable = true;
        package = pkgs.unstable.prowlarr;
        dataDir = "/nahar/prowlarr";
        port = 9696;
        openFirewall = true;
        hardening = true;
        apiKeyFile = config.sops.secrets."arr/prowlarr/apiKey".path;
      };
      # Radarr
      radarr = {
        enable = true;
        instances = {
          movies1080p = {
            enable = true;
            package = pkgs.unstable.radarr;
            dataDir = "/nahar/radarr/1080p";
            extraEnvVarFile = config.sops.secrets."arr/radarr/1080p/extraEnvVars".path;
            moviesDir = "/moria/media/Movies";
            user = "radarr";
            group = "kah";
            port = 7878;
            openFirewall = true;
            hardening = true;
            apiKeyFile = config.sops.secrets."arr/radarr/1080p/apiKey".path;
          };
          moviesAnime = {
            enable = true;
            package = pkgs.unstable.radarr;
            dataDir = "/nahar/radarr/anime";
            extraEnvVarFile = config.sops.secrets."arr/radarr/anime/extraEnvVars".path;
            moviesDir = "/moria/media/Anime/Movies";
            user = "radarr";
            group = "kah";
            port = 7879;
            openFirewall = true;
            hardening = true;
            apiKeyFile = config.sops.secrets."arr/radarr/anime/apiKey".path;
          };
        };
      };
      # Sonarr
      sonarr = {
        enable = true;
        instances = {
          tv1080p = {
            enable = true;
            package = pkgs.unstable.sonarr;
            dataDir = "/nahar/sonarr/1080p";
            extraEnvVarFile = config.sops.secrets."arr/sonarr/1080p/extraEnvVars".path;
            tvDir = "/moria/media/TV";
            user = "sonarr";
            group = "kah";
            port = 8989;
            openFirewall = true;
            hardening = true;
            apiKeyFile = config.sops.secrets."arr/sonarr/1080p/apiKey".path;
          };
          anime = {
            enable = true;
            package = pkgs.unstable.sonarr;
            dataDir = "/nahar/sonarr/anime";
            extraEnvVarFile = config.sops.secrets."arr/sonarr/anime/extraEnvVars".path;
            tvDir = "/moria/media/Anime/Shows";
            user = "sonarr";
            group = "kah";
            port = 8990;
            openFirewall = true;
            hardening = true;
            apiKeyFile = config.sops.secrets."arr/sonarr/anime/apiKey".path;
          };
        };
      };
      # Sabnzbd
      sabnzbd = {
        enable = true;
        package = pkgs.unstable.sabnzbd;
        configFile = "/nahar/sabnzbd/sabnzbd.ini";
        port = 8457;
        user = "sabnzbd";
        group = "kah";
        # Security hardening.
        dataDir = "/nahar/sabnzbd";
        downloadsDir = "/eru/media/sabnzbd";
        hardening = true;
        openFirewall = true;
      };
      # Unpackerr
      unpackerr = {
        enable = true;
        package = pkgs.unstable.unpackerr;
        configFile = "/tmp/unpackerr/config.yaml";
        extraEnvVarsFile = config.sops.secrets."arr/unpackerr/extraEnvVars".path;
        user = "unpackerr";
        group = "kah";
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
        user = "qbittorrent";
        group = "kah";
        dataDir = "/nahar/qbittorrent";
        downloadsDir = "/eru/media/qb/downloads";
        webuiPort = 8456;
        openFirewall = true;
        hardening = true;
        qbittorrentPort = 50413;
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
