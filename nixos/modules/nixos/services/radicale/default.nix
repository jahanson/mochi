{ lib, config, ... }:
with lib;
let
  cfg = config.mySystem.${category}.${app};
  app = "radicale";
  category = "services";
  user = app; #string
  group = app; #string
  port = 5232; #int
  appFolder = "/var/lib/${app}";
  url = "${app}.jahanson.tech";
in
{
  options.mySystem.${category}.${app} =
    {
      enable = mkEnableOption "${app}";
      addToHomepage = mkEnableOption "Add ${app} to homepage" // { default = true; };
      monitor = mkOption
        {
          type = lib.types.bool;
          description = "Enable gatus monitoring";
          default = true;
        };
      prometheus = mkOption
        {
          type = lib.types.bool;
          description = "Enable prometheus scraping";
          default = true;
        };
      backups = mkOption
        {
          type = lib.types.bool;
          description = "Enable local backups";
          default = true;
        };
    };

  config = mkIf cfg.enable {

    ## Secrets
    sops.secrets."${category}/${app}/htpasswd" = {
      sopsFile = ./secrets.sops.yaml;
      owner = user;
      inherit group;
      restartUnits = [ "${app}.service" ];
    };

    users.users.jahanson.extraGroups = [ group ];

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      hideMounts = true;
      directories = [ "/var/lib/radicale/" ];
    };

    ## service
    services.radicale = {
      enable = true;
      settings = {
        server.hosts = [ "0.0.0.0:${builtins.toString port}" ];
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets."${category}/${app}/htpasswd".path;
          htpasswd_encryption = "plain";
          realm = "Radicale - Password Required";
        };
        storage.filesystem_folder = "/var/lib/radicale/collections";
      };
    };

    ### gatus integration
    mySystem.services.gatus.monitors = mkIf cfg.monitor [
      {
        name = app;
        group = "${category}";
        url = "https://${url}";
        interval = "1m";
        conditions = [ "[CONNECTED] == true" "[STATUS] == 200" "[RESPONSE_TIME] < 50" ];
      }
    ];

    ### Ingress
    services.nginx.virtualHosts.${host} = {
      useACMEHost = config.networking.domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString port}";
      };
    };

    ### firewall config

    # networking.firewall = mkIf cfg.openFirewall {
    #   allowedTCPPorts = [ port ];
    #   allowedUDPPorts = [ port ];
    # };

    ### backups
    warnings = [
      (mkIf (!cfg.backups && config.mySystem.purpose != "Development")
        "WARNING: Backups for ${app} are disabled!")
    ];

    services.restic.backups = mkIf cfg.backups (config.lib.mySystem.mkRestic
      {
        inherit app user;
        paths = [ appFolder ];
        inherit appFolder;
      });
  };
}
