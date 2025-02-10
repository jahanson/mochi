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
      enable = mkEnableOption "Database configuration for Sonarr";
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
    enable = mkEnableOption "Sonarr (global)";

    instances = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "Sonarr (instance)";

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
                default = "/var/lib/sonarr/${name}";
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

              extraEnvVars = mkOption {
                type = types.attrs;
                default = { };
                example = {
                  MY_VAR = "my value";
                };
                description = "Extra environment variables for sonarr.";
              };

              extraEnvVarFile = mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                example = "/run/secrets/sonarr_extra_env";
                description = "Extra environment file for Sonarr.";
              };
            };
          }
        )
      );
      default = { };
      description = "Sonarr instance configurations.";
    };
  };

  config = mkIf cfg.enable {
    # Add assertions for all instances
    assertions = flatten (
      mapAttrsToList (
        name: instanceCfg:
        if instanceCfg.enable then
          [
            {
              assertion = !(instanceCfg.db.host != "" && instanceCfg.db.hostFile != "");
              message = "Specify either a direct database host via db.host or a file via db.hostFile (leave direct host empty).";
            }
            {
              assertion = !(instanceCfg.db.user != "sonarr" && instanceCfg.db.userFile != "");
              message = "Specify either a direct database user via db.user or a file via db.userFile.";
            }
            {
              assertion = !(instanceCfg.apiKey != "" && instanceCfg.apiKeyFile != "");
              message = "Specify either a direct API key via apiKey or a file via apiKeyFile (leave direct API key empty).";
            }
          ]
        else
          [ ]
      ) cfg.instances
    );

    # Create systemd tmpfiles rules for each enabled instance
    systemd.tmpfiles.rules = flatten (
      mapAttrsToList (
        name: instanceCfg:
        if instanceCfg.enable then
          [
            "d ${instanceCfg.dataDir} 0775 ${instanceCfg.user} ${instanceCfg.group}"
          ]
        else
          [ ]
      ) cfg.instances
    );

    # Create services for each enabled instance
    systemd.services = mapAttrs' (
      name: instanceCfg:
      nameValuePair "sonarr-${name}" (
        mkIf instanceCfg.enable {
          description = "Sonarr (${name})";
          after = [
            "network.target"
            "nss-lookup.target"
          ];
          wantedBy = [ "multi-user.target" ];
          environment = lib.mkMerge [
            {
              SONARR__APP__INSTANCENAME = name;
              SONARR__APP__THEME = "dark";
              SONARR__AUTH__METHOD = "External";
              SONARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
              SONARR__LOG__DBENABLED = "False";
              SONARR__LOG__LEVEL = "info";
              SONARR__SERVER__PORT = toString instanceCfg.port;
              SONARR__UPDATE__BRANCH = "develop";
            }
            (lib.mkIf instanceCfg.db.enable {
              SONARR__POSTGRES__PORT = toString instanceCfg.db.port;
              SONARR__POSTGRES__MAINDB = instanceCfg.db.dbname;
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
              RuntimeDirectory = "sonarr-${name}";
              LogsDirectory = "sonarr-${name}";
              RuntimeDirectoryMode = "0750";
              Restart = "on-failure";
              RestartSec = 5;
            }
            (lib.mkIf instanceCfg.hardening {
              CapabilityBoundingSet = [ "" ];
              DeviceAllow = [ "" ];
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
                instanceCfg.tvDir
                "/var/log/sonarr-${name}"
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
                "mnt"
              ];
              RestrictSUIDSGID = true;
              SystemCallArchitectures = "native";
              SystemCallFilter = [
                "@system-service"
              ];
            })
            (lib.mkIf instanceCfg.db.enable {
              ExecStartPre = "+${pkgs.writeShellScript "sonarr-${name}-pre-script" ''
                    mkdir -p /run/sonarr-${name}
                    rm -f /run/sonarr-${name}/secrets.env

                # Helper function to safely write variables
                write_var() {
                  local var_name="$1"
                  local value="$2"
                  if [ -n "$value" ]; then
                        printf "%s=%s\n" "$var_name" "$value" >> /run/sonarr-${name}/secrets.env
                  fi
                }

                # API Key (direct value or file)
                    if [ -n "${instanceCfg.apiKey}" ]; then
                      write_var "SONARR__AUTH__APIKEY" "${instanceCfg.apiKey}"
                else
                      write_var "SONARR__AUTH__APIKEY" "$(cat ${instanceCfg.apiKeyFile})"
                fi

                # Database Configuration
                    write_var "SONARR__POSTGRES__HOST" "$([ -n "${instanceCfg.db.host}" ] && echo "${instanceCfg.db.host}" || cat "${instanceCfg.db.hostFile}")"
                    write_var "SONARR__POSTGRES__USER" "$([ -n "${instanceCfg.db.userFile}" ] && cat "${instanceCfg.db.userFile}" || echo "${instanceCfg.db.user}")"
                    write_var "SONARR__POSTGRES__PASSWORD" "$(cat ${instanceCfg.db.passwordFile})"

                # Final permissions
                    chmod 600 /run/sonarr-${name}/secrets.env
                    chown ${instanceCfg.user}:${instanceCfg.group} /run/sonarr-${name}/secrets.env
              ''}";

              EnvironmentFile = (
                [ "-/run/sonarr-${name}/secrets.env" ]
                ++ lib.optional (
                  instanceCfg.extraEnvVarFile != null && instanceCfg.extraEnvVarFile != ""
                ) instanceCfg.extraEnvVarFile
              );
            })
          ];
        }
      )
    ) cfg.instances;

    # Firewall configurations
    networking.firewall = mkMerge (
      mapAttrsToList (
        name: instanceCfg:
        mkIf (instanceCfg.enable && instanceCfg.openFirewall) {
          allowedTCPPorts = [ instanceCfg.port ];
        }
      ) cfg.instances
    );

    # Users and groups
    users = mkMerge (
      mapAttrsToList (
        name: instanceCfg:
        mkIf instanceCfg.enable {
          groups.${instanceCfg.group} = { };
          users = mkIf (instanceCfg.user == "sonarr") {
            sonarr = {
              inherit (instanceCfg) group;
              isSystemUser = true;
              # home = instanceCfg.dataDir;
              home = "/nahar/sonarr";
            };
          };
        }
      ) cfg.instances
    );
  };
}
