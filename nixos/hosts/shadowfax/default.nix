{
  config,
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

  environment = {
    sessionVariables = {
      # Wayland and Chromium/Electron apps.
      NIXOS_OZONE_WL = "1";
    };
    # System packages
    systemPackages = with pkgs; [
      inputs.zen-browser.packages."${system}".default # beta
      inputs.ghostty.packages."${system}".default # terminal
      pavucontrol # Pulseaudio volume control
      zulu
      # dev
      uv
      # fun
      fastfetch
      prismlauncher # Minecraft launcher
      # Scripts
      pushoverNotify
      refreshSeries
    ];
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

  # enable docker socket at /run/docker.sock
  virtualisation.podman.dockerSocket.enable = true;

  programs = {
    # 1Password cli
    _1password.enable = true;
    _1password-gui.enable = true;

    # Mosh
    mosh = {
      enable = true;
      openFirewall = true;
    };

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
      # Soft-serve
      23231 # SSH
      23232 # HTTP
      9418 # Git
      # scrypted
      # 45005
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
        package = pkgs.fabricServers.fabric-1_21_4;

        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (
            builtins.attrValues {
              Fabric-API = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/ZNwYCTsk/fabric-api-0.118.0%2B1.21.4.jar";
                sha512 = "1e0d31b6663dc2c7be648f3a5a9cf7b698b9a0fd0f7ae16d1d3f32d943d7c5205ff63a4f81b0c4e94a8997482cce026b7ca486e99d9ce35ac069aeb29b02a30d";
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
      package = pkgs.unstable.soft-serve;
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
      scrypted.enable = false;
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

      zfs-nightly-snap.enable = true;
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
