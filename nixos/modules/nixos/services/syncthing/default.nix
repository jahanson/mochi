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
    user = lib.mkOption {
      type = lib.types.str;
      description = "The user to run Syncthing as";
    };
  };

  config = lib.mkIf cfg.enable {
    # sops
    sops.secrets = {
      "username" = {
        sopsFile = ./secrets.sops.yaml;
        owner = "jahanson";
        mode = "400";
        restartUnits = [ "syncthing.service" ];
      };
      "password" = {
        sopsFile = ./secrets.sops.yaml;
        owner = "jahanson";
        mode = "400";
        restartUnits = [ "syncthing.service" ];
      };
    };

    services = {
      syncthing = {
        enable = true;
        user = cfg.user;
        dataDir = "/home/${cfg.user}/";
        openDefaultPorts = true;
        key = "${cfg.privateKeyPath}";
        cert = "${cfg.publicCertPath}";
        settings = import ./config { inherit (config) sops; };
      };
    };
    # Don't create default ~/Sync folder
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
