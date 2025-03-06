{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.services.qbittorrent;
in {
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
      description = "Open firewall ports for qBittorrent";
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
    users.groups.${cfg.group} = {};
    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        inherit (cfg) group;
        isSystemUser = true;
        home = cfg.dataDir;
      };
    };

    environment.systemPackages = [
      cfg.package
    ];

    systemd.services.qbittorrent = {
      description = "qbittorrent server";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "nss-lookup.target"];
      environment = {
        QBT_CONFIRM_LEGAL_NOTICE = "1";
        QBT_WEBUI_PORT = toString cfg.webuiPort;
        QBT_TORRENTING_PORT = toString cfg.qbittorrentPort;
        QBT_DOWNLOADS_PATH = "${cfg.downloadsDir}";
        HOME = cfg.dataDir;
        XDG_CONFIG_HOME = cfg.dataDir;
        XDG_DATA_HOME = cfg.dataDir;
        CONFIG_DIR = "${cfg.dataDir}/qBittorrent";
        CONFIG_FILE = "${cfg.dataDir}/qBittorrent/config/qBittorrent.conf";
        LOG_DIR = "${cfg.dataDir}/logs";
        LOG_FILE = "${cfg.dataDir}/logs/qbittorrent.log";
      };

      serviceConfig = lib.mkMerge [
        {
          ExecStart = "${cfg.package}/bin/qbittorrent-nox --profile=${cfg.dataDir}";
          Restart = "on-failure";
          RestartSec = 5;
          User = cfg.user;
          Group = cfg.group;
        }
        (lib.mkIf cfg.hardening {
          CapabilityBoundingSet = [""];
          DeviceAllow = [""];
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
          ReadWritePaths = [
            cfg.dataDir
            cfg.downloadsDir
          ];
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
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
        })
      ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.webuiPort
        cfg.qbittorrentPort
      ];
      allowedUDPPorts = [cfg.qbittorrentPort];
    };
  };
}
