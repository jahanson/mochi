{ lib, config, ... }:
with lib;
let
  cfg = config.mySystem.services.onepassword-connect;
in
{
  options.mySystem.services.onepassword-connect = {
    enable = mkEnableOption "onepassword-connect";
    apiVersion = lib.mkOption {
      type = lib.types.str;
      # renovate: depName=docker.io/1password/connect-api datasource=docker
      default = "1.7.3@sha256:0601c7614e102eada268dbda6ba4b5886ce77713be2c332ec6a2fd0f028484ba";
    };
    syncVersion = lib.mkOption {
      type = lib.types.str;
      # renovate: depName=docker.io/1password/connect-sync datasource=docker
      default = "1.7.3@sha256:2f17621c7eb27bbcb1f86bbc5e5a5198bf54ac3b9c2ffac38064d03c932b07d5";
    };
    credentialsFile = lib.mkOption {
      type = lib.types.path;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/onepassword-connect/data";
    };
  };

  config = mkIf cfg.enable {
    # Create data dir
    system.activationScripts.makeOnePasswordConnectDataDir = lib.stringAfter [ "var" ] ''
      mkdir -p "${cfg.dataDir}"
      chown -R 999:999 ${cfg.dataDir}
    '';

    # Enable onepassword-connect containers.
    virtualisation.oci-containers.containers = {
      onepassword-connect-api = {
        image = "docker.io/1password/connect-api:${cfg.apiVersion}";
        autoStart = true;
        ports = [ "8080:8080" ];
        volumes = [
          "${cfg.credentialsFile}:/home/opuser/.op/1password-credentials.json"
          "${cfg.dataDir}:/home/opuser/.op/data"
        ];
      };

      onepassword-connect-sync = {
        image = "docker.io/1password/connect-sync:${cfg.syncVersion}";
        autoStart = true;
        ports = [ "8081:8080" ];
        volumes = [
          "${cfg.credentialsFile}:/home/opuser/.op/1password-credentials.json"
          "${cfg.dataDir}:/home/opuser/.op/data"
        ];
      };
    };

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [ cfg.dataDir ];
    };
  };
}
