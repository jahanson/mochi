{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
with lib;
let
  cfg = config.mySystem.services.prowlarr;
  dbOptions = {
    options = {
      enable = mkEnableOption "Database configuration for Prowlarr";
      host = mkOption {
        type = types.str;
        default = "";
        example = "127.0.0.1";
        description = "Direct database host (mutually exclusive with hostFile)";
      };
      hostFile = mkOption {
        type = types.str;
        default = "";
        example = "/run/secrets/prowlarr_db_host";
        description = "Database host from a file (mutually exclusive with host)";
      };
      port = mkOption {
        type = types.port;
        default = "5432";
        description = "Database port";
      };
      user = mkOption {
        type = types.str;
        default = "prowlarr";
        description = "Direct database user (mutually exclusive with userFile)";
      };
      userFile = mkOption {
        type = types.str;
        default = "";
        example = "/run/secrets/prowlarr_db_user";
        description = "Database user from a file (mutually exclusive with user)";
      };
      passwordFile = mkOption {
        type = types.path;
        default = "/run/secrets/prowlarr_db_password";
        description = "Database password from a file (always used)";
      };
      dbname = mkOption {
        type = types.str;
        default = "prowlarr_main";
        description = "Database name";
      };
    };
  };
in
{
  options.mySystem.services.prowlarr = {
    enable = mkEnableOption "Prowlarr";

    package = mkPackageOption pkgs "prowlarr" { };

    user = mkOption {
      type = types.str;
      default = "prowlarr";
      description = "User account under which Prowlarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "prowlarr";
      description = "Group under which Prowlarr runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/prowlarr";
      description = "Storage directory for Prowlarr data";
    };

    port = mkOption {
      type = types.port;
      default = 9696;
      description = "Port for Prowlarr web interface";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall ports for Prowlarr";
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
      description = "Direct API key for Prowlarr (mutually exclusive with apiKeyFile)";
    };

    apiKeyFile = mkOption {
      type = types.path;
      default = "/run/secrets/prowlarr_api_key";
      description = "API key for Prowlarr from a file (mutually exclusive with apiKey)";
    };

    extraEnvVars = mkOption {
      type = types.attrs;
      default = { };
      example = {
        MY_VAR = "my value";
      };
      description = "Extra environment variables for Prowlarr.";
    };

    extraEnvVarFile = mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/prowlarr_extra_env";
      description = "Extra environment file for Prowlarr.";
    };

    db = mkOption {
      type = types.submodule dbOptions;
      example = {
        enable = true;
        host = "10.5.0.5"; # or use hostFile
        port = "5432";
        user = "prowlarr"; # or userFile
        passwordFile = "/run/secrets/prowlarr_db_password";
        dbname = "prowlarr_main";
      };
      description = "Database settings for Prowlarr.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.db.host != "" && cfg.db.hostFile != "");
        message = "Specify either a direct database host via db.host or a file via db.hostFile (leave direct host empty).";
      }
      {
        assertion = !(cfg.db.user != "prowlarr" && cfg.db.userFile != "");
        message = "Specify either a direct database user via db.user or a file via db.userFile.";
      }
      {
        assertion = !(cfg.apiKey != "" && cfg.apiKeyFile != "");
        message = "Specify either a direct API key via apiKey or a file via apiKeyFile (leave direct API key empty).";
      }
    ];

    systemd.services.prowlarr = {
      description = "Prowlarr";
      after = [
        "network.target"
        "nss-lookup.target"
      ];
      wantedBy = [ "multi-user.target" ];
      environment = lib.mkMerge [
        {
          PROWLARR__APP__INSTANCENAME = "Prowlarr";
          PROWLARR__APP__THEME = "dark";
          PROWLARR__AUTH__METHOD = "External";
          PROWLARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
          PROWLARR__LOG__DBENABLED = "False";
          PROWLARR__LOG__LEVEL = "info";
          PROWLARR__SERVER__PORT = toString cfg.port;
          PROWLARR__UPDATE__BRANCH = "develop";
        }
        (lib.mkIf cfg.db.enable {
          PROWLARR__POSTGRES__PORT = toString cfg.db.port;
          PROWLARR__POSTGRES__MAINDB = cfg.db.dbname;
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
          RuntimeDirectory = "prowlarr";
          LogsDirectory = "prowlarr";
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
            "/var/log/prowlarr"
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
          ExecStartPre = "+${pkgs.writeShellScript "prowlarr-pre-script" ''
            mkdir -p /run/prowlarr
            rm -f /run/prowlarr/secrets.env

            # Helper function to safely write variables
            write_var() {
              local var_name="$1"
              local value="$2"
              if [ -n "$value" ]; then
                printf "%s=%s\n" "$var_name" "$value" >> /run/prowlarr/secrets.env
              fi
            }

            # API Key (direct value or file)
            if [ -n "${cfg.apiKey}" ]; then
              write_var "PROWLARR__AUTH__APIKEY" "${cfg.apiKey}"
            else
              write_var "PROWLARR__AUTH__APIKEY" "$(cat ${cfg.apiKeyFile})"
            fi

            # Database Configuration
            write_var "PROWLARR__POSTGRES__HOST" "$([ -n "${cfg.db.host}" ] && echo "${cfg.db.host}" || cat "${cfg.db.hostFile}")"
            write_var "PROWLARR__POSTGRES__USER" "$([ -n "${cfg.db.user}" ] && echo "${cfg.db.user}" || cat "${cfg.db.userFile}")"
            write_var "PROWLARR__POSTGRES__PASSWORD" "$(cat ${cfg.db.passwordFile})"

            # Final permissions
            chmod 600 /run/prowlarr/secrets.env
            chown ${cfg.user}:${cfg.group} /run/prowlarr/secrets.env
          ''}";

          EnvironmentFile = (
            [ "-/run/prowlarr/secrets.env" ]
            ++ lib.optional (cfg.extraEnvVarFile != null && cfg.extraEnvVarFile != "") cfg.extraEnvVarFile
          );
        })
      ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users.groups.${cfg.group} = { };
    users.users = mkIf (cfg.user == "prowlarr") {
      prowlarr = {
        inherit (cfg) group;
        isSystemUser = true;
        home = cfg.dataDir;
      };
    };
  };
}
