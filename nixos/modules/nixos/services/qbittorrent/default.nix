{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mySystem.services.qbittorrent;
in
{
  options.mySystem.services.qbittorrent = {
    enable = mkEnableOption "qBittorrent";

    package = mkOption {
      type = types.package;
      default = pkgs.qbittorrent;
      description = "qBittorrent package to use";
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = "User account under which qBittorrent runs";
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = "Group under which qBittorrent runs";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = "Storage directory for qBittorrent data";
    };

    downloadsDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent/downloads";
      description = "Location to store the downloads";
    };

    webuiPort = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for qBittorrent web interface";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall port for web interface";
    };

    hardening = mkOption {
      type = types.bool;
      default = true;
      description = "Enable security hardening features";
    };

    qbittorrentPort = mkOption {
      type = types.port;
      default = 6881;
      description = "Port used for peer connections";
    };
  };

  config = mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        inherit (cfg) group;
        isSystemUser = true;
        home = cfg.dataDir;
      };
    };

    environment.systemPackages = [
    ];

    systemd.services.qbittorrent = {
      environment = {
        QBT_CONFIRM_LEGAL_NOTICE = "1";
        QBT_WEBUI_PORT = toString cfg.webuiPort;
        QBT_TORRENTING_PORT = toString cfg.qbittorrentPort;
        QBT_DOWNLOADS_PATH = "${cfg.dataDir}/downloads";
        XDG_CONFIG_HOME = cfg.dataDir;
        XDG_DATA_HOME = cfg.dataDir;
        CONFIG_DIR = "${cfg.dataDir}";
        CONFIG_FILE = "${cfg.dataDir}/qBittorrent.conf";
        LOG_DIR = "${cfg.dataDir}/logs";
        LOG_FILE = "${cfg.dataDir}/logs/qbittorrent.log";
      };

      preStart = ''
                # Ensure config directory exists
                mkdir -p "$CONFIG_DIR"

                # Set up log directory and file
                mkdir -p "$LOG_DIR"

                # Copy default config if it doesn't exist
                if [[ ! -f "$CONFIG_FILE" ]]; then
                  cat > "$CONFIG_FILE" << EOF
        [BitTorrent]
        Session\DefaultSavePath=${cfg.downloadsDir}
        Session\Port=${toString cfg.qbittorrentPort}
        Session\TempPath=${cfg.downloadsDir}/temp
        EOF
                fi

                # Ensure correct permissions
                chown -R ${cfg.user}:${cfg.group} "$CONFIG_DIR"
      '';

      serviceConfig =
        {
          ExecStart = "${cfg.package}/bin/qbittorrent-nox --profile=${cfg.dataDir}";
          ReadWritePaths = [
            "/nahar/qbittorrent"
            "/eru/media"
          ];
          Restart = "on-failure";
          RestartSec = 5;
        }
        // lib.mkIf cfg.hardening {
          CapabilityBoundingSet = [ ];
          DevicePolicy = "closed";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = "read-only";
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
            "AF_UNIX"
          ];
          RestrictNamespaces = [
            "uts"
            "ipc"
            "pid"
            "user"
            "cgroup"
            "net"
          ];
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];
        };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.webuiPort
        cfg.qbittorrentPort
      ];
      allowedUDPPorts = [ cfg.qbittorrentPort ];
    };
  };
}
