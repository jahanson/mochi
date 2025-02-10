{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
with lib; let
  cfg = config.mySystem.services.radarr;
  dbOptions = {
    options = {
      enable = mkEnableOption "Database configuration for Radarr";
      host = mkOption {
        type = types.str;
        default = "";
        example = "127.0.0.1";
        description = "Direct database host (mutually exclusive with hostFile)";
      };
      hostFile = mkOption {
        type = types.str;
        default = "";
        example = "/run/secrets/radarr_db_host";
        description = "Database host from a file (mutually exclusive with host)";
      };
      port = mkOption {
        type = types.port;
        default = "5432";
        description = "Database port";
      };
      user = mkOption {
        type = types.str;
        default = "radarr";
        description = "Direct database user (mutually exclusive with userFile)";
      };
      userFile = mkOption {
        type = types.str;
        default = "";
        example = "/run/secrets/radarr_db_user";
        description = "Database user from a file (mutually exclusive with user)";
      };
      passwordFile = mkOption {
        type = types.path;
        default = "/run/secrets/radarr_db_password";
        description = "Database password from a file (always used)";
      };
      dbname = mkOption {
        type = types.str;
        default = "radarr_main";
        description = "Database name";
      };
    };
  };
in {
  options.mySystem.services.radarr = {
    enable = mkEnableOption "Radarr";

    package = mkPackageOption pkgs "Radarr" {};

    user = mkOption {
      type = types.str;
      default = "radarr";
      description = "User account under which radarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "radarr";
      description = "Group under which radarr runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/radarr";
      description = "Storage directory for radarr data";
    };

    moviesDir = mkOption {
      type = types.path;
      default = "/mnt/media/movies";
      description = "Directory where movies are stored";
    };

    port = mkOption {
      type = types.port;
      default = 7878;
      description = "Port for radarr web interface";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall ports for radarr";
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
      description = "Direct API key for radarr (mutually exclusive with apiKeyFile)";
    };

    apiKeyFile = mkOption {
      type = types.path;
      default = "/run/secrets/radarr_api_key";
      description = "API key for radarr from a file (mutually exclusive with apiKey)";
    };

    db = mkOption {
      type = types.submodule dbOptions;
      example = {
        enable = true;
        host = "10.5.0.5"; # or use hostFile
        port = "5432";
        user = "radarr"; # or userFile
        passwordFile = "/run/secrets/radarr_db_password";
        dbname = "radarr_main";
      };
      description = "Database settings for radarr.";
    };

    extraEnvVars = mkOption {
      type = types.attrs;
      default = {};
      example = {
        MY_VAR = "my value";
      };
      description = "Extra environment variables for radarr.";
    };

    extraEnvVarFile = mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/radarr_extra_env";
      description = "Extra environment file for Radarr.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.db.host != "" && cfg.db.hostFile != "");
        message = "Specify either a direct database host via db.host or a file via db.hostFile (leave direct host empty).";
      }
      {
        assertion = !(cfg.db.user != "radarr" && cfg.db.userFile != "");
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

    systemd.services.radarr = {
      description = "Radarr";
      after = [
        "network.target"
        "nss-lookup.target"
      ];
      wantedBy = ["multi-user.target"];
      environment = lib.mkMerge [
        {
          RADARR__APP__INSTANCENAME = "Radarr";
          RADARR__APP__THEME = "dark";
          RADARR__AUTH__METHOD = "External";
          RADARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
          RADARR__LOG__DBENABLED = "False";
          RADARR__LOG__LEVEL = "info";
          RADARR__SERVER__PORT = toString cfg.port;
          RADARR__UPDATE__BRANCH = "develop";
        }
        (lib.mkIf cfg.db.enable {
          RADARR__POSTGRES__PORT = toString cfg.db.port;
          RADARR__POSTGRES__MAINDB = cfg.db.dbname;
        })
        cfg.extraEnvVars
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
          RuntimeDirectory = "radarr";
          LogsDirectory = "radarr";
          RuntimeDirectoryMode = "0750";
          Restart = "on-failure";
          RestartSec = 5;
        }
        (lib.mkIf cfg.hardening {
          CapabilityBoundingSet = [""];
          DeviceAllow = [""];
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
            cfg.moviesDir
            "/var/log/radarr"
            "/eru/media"
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
            #"~@privileged"
            # .Net CLR requirement
            #"~@resources"
          ];
        })
        (lib.mkIf cfg.db.enable {
          ExecStartPre = "+${pkgs.writeShellScript "radarr-pre-script" ''
            mkdir -p /run/radarr
            rm -f /run/radarr/secrets.env

            # Helper function to safely write variables
            write_var() {
              local var_name="$1"
              local value="$2"
              if [ -n "$value" ]; then
                printf "%s=%s\n" "$var_name" "$value" >> /run/radarr/secrets.env
              fi
            }

            # API Key (direct value or file)
            if [ -n "${cfg.apiKey}" ]; then
              write_var "RADARR__AUTH__APIKEY" "${cfg.apiKey}"
            else
              write_var "RADARR__AUTH__APIKEY" "$(cat ${cfg.apiKeyFile})"
            fi

            # Database Configuration
            write_var "RADARR__POSTGRES__HOST" "$([ -n "${cfg.db.host}" ] && echo "${cfg.db.host}" || cat "${cfg.db.hostFile}")"
            write_var "RADARR__POSTGRES__USER" "$([ -n "${cfg.db.user}" ] && echo "${cfg.db.user}" || cat "${cfg.db.userFile}")"
            write_var "RADARR__POSTGRES__PASSWORD" "$(cat ${cfg.db.passwordFile})"

            # Final permissions
            chmod 600 /run/radarr/secrets.env
            chown ${cfg.user}:${cfg.group} /run/radarr/secrets.env
          ''}";

          EnvironmentFile = (
            ["-/run/radarr/secrets.env"]
            ++ lib.optional (cfg.extraEnvVarFile != null && cfg.extraEnvVarFile != "") cfg.extraEnvVarFile
          );
        })
      ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };

    users.groups.${cfg.group} = {};
    users.users = mkIf (cfg.user == "radarr") {
      radarr = {
        inherit (cfg) group;
        isSystemUser = true;
        home = cfg.dataDir;
      };
    };
  };
}
