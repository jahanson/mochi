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
    enable = mkEnableOption "Radarr (global)";

    instances = mkOption {
      type = types.attrsOf (
        types.submodule (
          {name, ...}: {
            options = {
              enable = mkEnableOption "Radarr (instance)";

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
                default = "/var/lib/radarr/${name}";
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
                default = {
                  enable = false;
                  host = "";
                  port = "5432";
                  user = "";
                  passwordFile = "";
                  dbname = "";
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
          }
        )
      );
      default = {};
      description = "Radarr instance configurations.";
    };
  };

  config = mkIf cfg.enable {
    # Add assertions for all instances
    assertions = flatten (
      mapAttrsToList (
        name: instanceCfg:
          if instanceCfg.enable
          then [
            {
              assertion = !(instanceCfg.db.host != "" && instanceCfg.db.hostFile != "");
              message = "Specify either a direct database host via db.host or a file via db.hostFile (leave direct host empty).";
            }
            {
              assertion = !(instanceCfg.db.user != "radarr" && instanceCfg.db.userFile != "");
              message = "Specify either a direct database user via db.user or a file via db.userFile.";
            }
            {
              assertion = !(instanceCfg.apiKey != "" && instanceCfg.apiKeyFile != "");
              message = "Specify either a direct API key via apiKey or a file via apiKeyFile (leave direct API key empty).";
            }
          ]
          else []
      )
      cfg.instances
    );

    # Create systemd tmpfiles rules for each enabled instance
    systemd.tmpfiles.rules = flatten (
      mapAttrsToList (
        name: instanceCfg:
          if instanceCfg.enable
          then [
            "d ${instanceCfg.dataDir} 0775 ${instanceCfg.user} ${instanceCfg.group}"
          ]
          else []
      )
      cfg.instances
    );

    # Create services for each enabled instance
    systemd.services =
      mapAttrs' (
        name: instanceCfg:
          nameValuePair "radarr-${name}" (
            mkIf instanceCfg.enable {
              description = "Radarr (${name})";
              after = [
                "network.target"
                "nss-lookup.target"
              ];
              wantedBy = ["multi-user.target"];
              environment = lib.mkMerge [
                {
                  RADARR__APP__INSTANCENAME = name;
                  RADARR__APP__THEME = "dark";
                  RADARR__AUTH__METHOD = "External";
                  RADARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
                  RADARR__LOG__DBENABLED = "False";
                  RADARR__LOG__LEVEL = "info";
                  RADARR__SERVER__PORT = toString instanceCfg.port;
                  RADARR__UPDATE__BRANCH = "develop";
                }
                (lib.mkIf instanceCfg.db.enable {
                  RADARR__POSTGRES__PORT = toString instanceCfg.db.port;
                  RADARR__POSTGRES__MAINDB = instanceCfg.db.dbname;
                })
                instanceCfg.extraEnvVars
              ];

              serviceConfig = lib.mkMerge [
                {
                  Type = "simple";
                  User = instanceCfg.user;
                  Group = instanceCfg.group;
                  ExecStart = utils.escapeSystemdExecArgs [
                    (lib.getExe instanceCfg.package)
                    "-nobrowser"
                    "-data=${instanceCfg.dataDir}"
                    "-port=${toString instanceCfg.port}"
                  ];
                  WorkingDirectory = instanceCfg.dataDir;
                  RuntimeDirectory = "radarr-${name}";
                  LogsDirectory = "radarr-${name}";
                  RuntimeDirectoryMode = "0750";
                  Restart = "on-failure";
                  RestartSec = 5;
                }
                (lib.mkIf instanceCfg.hardening {
                  CapabilityBoundingSet = [""];
                  DeviceAllow = [""];
                  DevicePolicy = "closed";
                  LockPersonality = true;
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
                    instanceCfg.dataDir
                    instanceCfg.moviesDir
                    "/var/log/radarr-${name}"
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
                  ];
                })
                {
                  ExecStartPre = "+${pkgs.writeShellScript "radarr-${name}-pre-script" ''
                    mkdir -p /run/radarr-${name}
                    rm -f /run/radarr-${name}/secrets.env

                    # Helper function to safely write variables
                    write_var() {
                      local var_name="$1"
                      local value="$2"
                      if [ -n "$value" ]; then
                        printf "%s=%s\n" "$var_name" "$value" >> /run/radarr-${name}/secrets.env
                      fi
                    }

                    # API Key (direct value or file)
                    if [ -n "${instanceCfg.apiKey}" ]; then
                      write_var "RADARR__AUTH__APIKEY" "${instanceCfg.apiKey}"
                    else
                      write_var "RADARR__AUTH__APIKEY" "$(cat ${instanceCfg.apiKeyFile})"
                    fi

                    ${lib.optionalString instanceCfg.db.enable ''
                      # Database Configuration
                      write_var "RADARR__POSTGRES__HOST" "$([ -n "${instanceCfg.db.host}" ] && echo "${instanceCfg.db.host}" || cat "${instanceCfg.db.hostFile}")"
                      write_var "RADARR__POSTGRES__USER" "$([ -n "${instanceCfg.db.userFile}" ] && cat "${instanceCfg.db.userFile}" || echo "${instanceCfg.db.user}")"
                      write_var "RADARR__POSTGRES__PASSWORD" "$(cat ${instanceCfg.db.passwordFile})"
                    ''}

                    # Final permissions
                    chmod 600 /run/radarr-${name}/secrets.env
                    chown ${instanceCfg.user}:${instanceCfg.group} /run/radarr-${name}/secrets.env
                  ''}";

                  EnvironmentFile = (
                    ["-/run/radarr-${name}/secrets.env"]
                    ++ lib.optional (
                      instanceCfg.extraEnvVarFile != null && instanceCfg.extraEnvVarFile != ""
                    )
                    instanceCfg.extraEnvVarFile
                  );
                }
              ];
            }
          )
      )
      cfg.instances;

    # Firewall configurations
    networking.firewall = mkMerge (
      mapAttrsToList (
        name: instanceCfg:
          mkIf (instanceCfg.enable && instanceCfg.openFirewall) {
            allowedTCPPorts = [instanceCfg.port];
          }
      )
      cfg.instances
    );

    # Users and groups
    users = mkMerge (
      mapAttrsToList (
        name: instanceCfg:
          mkIf instanceCfg.enable {
            groups.${instanceCfg.group} = {};
            users = mkIf (instanceCfg.user == "radarr") {
              radarr = {
                inherit (instanceCfg) group;
                isSystemUser = true;
                # home = instanceCfg.dataDir;
                home = "/nahar/radarr";
              };
            };
          }
      )
      cfg.instances
    );
  };
}
