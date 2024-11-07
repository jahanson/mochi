{
  config,
  lib,
  ...
}:
let
  cfg = config.mySystem.services.syncthing;
in
{
  options.mySystem.services.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
    publicCertPath = lib.mkOption {
      type = lib.types.path;
      description = "The public certificate for Syncthing";
    };
    privateKeyPath = lib.mkOption {
      type = lib.types.path;
      description = "The private key for Syncthing";
    };
  };

  config = lib.mkIf cfg.enable {
    # sops
    sops.secrets = {
      "username" = {
        sopsFile = ./secrets.sops.yaml;
        owner = "syncthing";
        mode = "400";
        restartUnits = [ "syncthing.service" ];
      };
      "password" = {
        sopsFile = ./secrets.sops.yaml;
        owner = "syncthing";
        mode = "400";
        restartUnits = [ "syncthing.service" ];
      };
    };

    services = {
      syncthing = {
        enable = true;
        openDefaultPorts = true;
        key = lib.mkIf (cfg.privateKeyPath != null) "${cfg.privateKeyPath}";
        cert = lib.mkIf (cfg.publicCertPath != null) "${cfg.publicCertPath}";
        settings = import ./config { inherit (config) sops; };
      };
    };
    # Don't create default ~/Sync folder
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
