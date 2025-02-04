{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.mySystem.services.unpackerr;
in
{
  options.mySystem.services.unpackerr = {
    enable = mkEnableOption "Unpackerr";

    package = mkPackageOption pkgs "unpackerr" { };

    user = mkOption {
      type = types.str;
      default = "unpackerr";
      description = "User account under which Unpackerr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "unpackerr";
      description = "Group under which Unpackerr runs.";
    };

    configFile = mkOption {
      type = types.path;
      default = "/var/lib/unpackerr/config.yaml";
      description = "Configuration file used by Unpackerr.";
    };

    extraEnvVarsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/unpackerr_extra_env";
      description = "Extra environment file for Unpackerr.";
    };
  };

  config = mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users = mkIf (cfg.user == "unpackerr") {
      unpackerr = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    systemd.services.unpackerr = {
      description = "Unpackerr service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = lib.mkForce (
          lib.concatStringsSep " " [
            "${cfg.package}/bin/unpackerr"
            "--config"
            "${cfg.configFile}"
          ]
        );

        EnvironmentFile = lib.optional (
          cfg.extraEnvVarsFile != null && cfg.extraEnvVarsFile != ""
        ) cfg.extraEnvVarsFile;
      };
    };
  };
}
