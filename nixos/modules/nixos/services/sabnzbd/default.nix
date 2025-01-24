{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.services.sabnzbd;
in {
  options = {
    mySystem.services.sabnzbd = {
      enable = mkEnableOption "sabnzbd";

      package = mkPackageOption pkgs "sabnzbd" {};

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/sabnzbd";
        description = "Path to the data directory.";
      };

      downloadsDir = mkOption {
        type = types.path;
        default = "/var/lib/sabnzbd/downloads";
        description = "Path to the data directory.";
      };

      configFile = mkOption {
        type = types.path;
        default = "/var/lib/sabnzbd/sabnzbd.ini";
        description = "Path to config file.";
      };

      user = mkOption {
        default = "sabnzbd";
        type = types.str;
        description = "User to run the service as";
      };

      group = mkOption {
        type = types.str;
        default = "sabnzbd";
        description = "Group to run the service as";
      };

      hardening = mkOption {
        type = types.bool;
        default = true;
        description = "Enable security hardening features";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the sabnzbd web interface";
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = "Port to listen on for the Web UI.";
      };

      pidFile = mkOption {
        type = types.str;
        default = "/run/sabnzbd/sabnzbd.pid";
        description = "Path to the PID file.";
      };

      bindAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "Address to bind to.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.groups.${cfg.group} = {};
    users.users = mkIf (cfg.user == "sabnzbd") {
      sabnzbd = {
        inherit (cfg) group;
        isSystemUser = true;
        home = cfg.dataDir;
      };
    };

    systemd.services.sabnzbd = {
      description = "sabnzbd server";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "nss-lookup.target"];
      environment = {
        HOME = cfg.dataDir;
      };
      serviceConfig = lib.mkMerge [
        {
          ExecStart = "${lib.getBin cfg.package}/bin/sabnzbd -d -f ${cfg.configFile} --server ${cfg.bindAddress}:${toString cfg.port} --pidfile ${cfg.pidFile}";
          PIDFile = cfg.pidFile;
          Type = "forking";
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = cfg.dataDir;
          RuntimeDirectory = "sabnzbd";
          LogsDirectory = "sabnzbd";
          TimeoutStartSec = 10;
          RuntimeDirectoryMode = "0750";
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
          ReadWritePaths = [
            cfg.dataDir
            cfg.downloadsDir
            "/var/log/sabnzbd"
          ];
        })
      ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
