{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
with lib;
let
  cfg = config.mySystem.services.sonarr;
  dbOptions = {
    options = {
      enable = mkEnableOption "Database configuration for sonarr";
      host = mkOption {
        type = types.str;
        default = "";
        example = "127.0.0.1";
        description = "Direct database host (mutually exclusive with hostFile)";
      };
      hostFile = mkOption {
        type = types.str;
        default = "";
        example = "/run/secrets/sonarr_db_host";
        description = "Database host from a file (mutually exclusive with host)";
      };
      port = mkOption {
        type = types.port;
        default = "5432";
        description = "Database port";
      };
      user = mkOption {
        type = types.str;
        default = "sonarr";
        description = "Direct database user (mutually exclusive with userFile)";
      };
      userFile = mkOption {
        type = types.str;
        default = "";
        example = "/run/secrets/sonarr_db_user";
        description = "Database user from a file (mutually exclusive with user)";
      };
      passwordFile = mkOption {
        type = types.path;
        default = "/run/secrets/sonarr_db_password";
        description = "Database password from a file (always used)";
      };
      dbname = mkOption {
        type = types.str;
        default = "sonarr_main";
        description = "Database name";
      };
    };
  };
in
{
  options.mySystem.services.sonarr = {
    enable = mkEnableOption "Sonarr";

    package = mkPackageOption pkgs "Sonarr" { };

    user = mkOption {
      type = types.str;
      default = "sonarr";
      description = "User account under which sonarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "sonarr";
      description = "Group under which sonarr runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/sonarr";
      description = "Storage directory for sonarr data";
    };

    tvDir = mkOption {
      type = types.path;
      default = "/mnt/media/tv";
      description = "Directory where tv shows are stored";
    };

    port = mkOption {
      type = types.port;
      default = 8989;
      description = "Port for sonarr web interface";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall ports for sonarr";
    };

    hardening = mkOption {
      type = types.bool;
      default = true;
      description = "Enable security hardening features";
    };

    apiKey = mkOption {
      type = types.str;
      default = "";
      example = "abc123";
      description = "Direct API key for sonarr (mutually exclusive with apiKeyFile)";
    };

    apiKeyFile = mkOption {
      type = types.path;
      default = "/run/secrets/sonarr_api_key";
      description = "API key for sonarr from a file (mutually exclusive with apiKey)";
    };

    db = mkOption {
      type = types.submodule dbOptions;
      example = {
        enable = true;
        host = "10.5.0.5"; # or use hostFile
        port = "5432";
        user = "sonarr"; # or userFile
        passwordFile = "/run/secrets/sonarr_db_password";
        dbname = "sonarr_main";
      };
      description = "Database settings for sonarr.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.db.host != "" && cfg.db.hostFile != "");
        message = "Specify either a direct database host via db.host or a file via db.hostFile (leave direct host empty).";
      }
      {
        assertion = !(cfg.db.user != "sonarr" && cfg.db.userFile != "");
        message = "Specify either a direct database user via db.user or a file via db.userFile.";
      }
      {
        assertion = !(cfg.apiKey != "" && cfg.apiKeyFile != "");
        message = "Specify either a direct API key via apiKey or a file via apiKeyFile (leave direct API key empty).";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0775 ${cfg.user} ${cfg.group}"
    ];

    systemd.services.sonarr = {
      description = "Sonarr";
      after = [
        "network.target"
        "nss-lookup.target"
      ];
      wantedBy = [ "multi-user.target" ];
      environment = lib.mkMerge [
        {
          SONARR__APP__INSTANCENAME = "Sonarr";
          SONARR__APP__THEME = "dark";
          SONARR__AUTH__METHOD = "External";
          SONARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
          SONARR__LOG__DBENABLED = "False";
          SONARR__LOG__LEVEL = "info";
          SONARR__SERVER__PORT = toString cfg.port;
          SONARR__UPDATE__BRANCH = "develop";
        }
        (lib.mkIf cfg.db.enable {
          SONARR__POSTGRES__PORT = toString cfg.db.port;
          SONARR__POSTGRES__MAINDB = cfg.db.dbname;
        })
      ];

      serviceConfig = lib.mkMerge [
        {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = utils.escapeSystemdExecArgs [
            (lib.getExe cfg.package)
            "-nobrowser"
            "-data=${cfg.dataDir}"
            "-port=${toString cfg.port}"
          ];
          WorkingDirectory = cfg.dataDir;
          RuntimeDirectory = "sonarr";
          LogsDirectory = "sonarr";
          RuntimeDirectoryMode = "0750";
          Restart = "on-failure";
          RestartSec = 5;
        }
        (lib.mkIf cfg.hardening {
          CapabilityBoundingSet = [ "" ];
          DeviceAllow = [ "" ];
          DevicePolicy = "closed";
          LockPersonality = true;
          # Needs access to .Net CLR memory space.
          MemoryDenyWriteExecute = false;
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
            cfg.tvDir
            "/var/log/sonarr"
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
            # .Net CLR requirement
            #"~@resources"
          ];
        })
        (lib.mkIf cfg.db.enable {
          ExecStartPre = "+${pkgs.writeShellScript "sonarr-pre-script" ''
            mkdir -p /run/sonarr
            rm -f /run/sonarr/secrets.env

            # Helper function to safely write variables
            write_var() {
              local var_name="$1"
              local value="$2"
              if [ -n "$value" ]; then
                printf "%s=%s\n" "$var_name" "$value" >> /run/sonarr/secrets.env
              fi
            }

            # API Key (direct value or file)
            if [ -n "${cfg.apiKey}" ]; then
              write_var "SONARR__AUTH__APIKEY" "${cfg.apiKey}"
            else
              write_var "SONARR__AUTH__APIKEY" "$(cat ${cfg.apiKeyFile})"
            fi

            # Database Configuration
            write_var "SONARR__POSTGRES__HOST" "$([ -n "${cfg.db.host}" ] && echo "${cfg.db.host}" || cat "${cfg.db.hostFile}")"
            write_var "SONARR__POSTGRES__USER" "$([ -n "${cfg.db.user}" ] && echo "${cfg.db.user}" || cat "${cfg.db.userFile}")"
            write_var "SONARR__POSTGRES__PASSWORD" "$(cat ${cfg.db.passwordFile})"

            # Final permissions
            chmod 600 /run/sonarr/secrets.env
            chown ${cfg.user}:${cfg.group} /run/sonarr/secrets.env
          ''}";

          EnvironmentFile = [ "-/run/sonarr/secrets.env" ];
        })
      ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users.groups.${cfg.group} = { };
    users.users = mkIf (cfg.user == "sonarr") {
      sonarr = {
        inherit (cfg) group;
        isSystemUser = true;
        home = cfg.dataDir;
      };
    };
  };
}
