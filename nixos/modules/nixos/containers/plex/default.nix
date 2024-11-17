{
  lib,
  config,
  ...
}:
with lib;
let
  app = "plex";
  # renovate: depName=ghcr.io/onedr0p/plex datasource=docker
  version = "1.40.1.8227-c0dd5a73e@sha256:a60bc6352543b4453b117a8f2b89549e458f3ed8960206d2f3501756b6beb519";
  image = "ghcr.io/onedr0p/plex:${version}";
  user = "kah"; # string
  group = "kah"; # string
  port = 32400; # int
  cfg = config.mySystem.services.${app};
in
{
  # Options
  options.mySystem.services.${app} = {
    enable = mkEnableOption "${app}";
    # TODO add to homepage
    # addToHomepage = mkEnableOption "Add ${app} to homepage" // {
    #   default = true;
    # };
    openFirewall = mkEnableOption "Open firewall for ${app}" // {
      default = true;
    };
  };

  # Implementation
  config = mkIf cfg.enable {
    # Container
    virtualisation.oci-containers.containers.${app} = {
      image = "${image}";
      user = "568:568";
      volumes = [
        "/nahar/containers/volumes/${app}:/config:rw"
        "/moria/media:/media:rw"
        # "/eru/backup/apps/plex:/config:rw"
      ];
      environment = {
        TZ = "America/Chicago";
        PLEX_ADVERTISE_URL = "https://${app}.hsn.dev";
        PLEX_NO_AUTH_NETWORKS = "10.1.1.0/24";
      };
      ports = [ "${port}:${port}" ]; # expose port
    };

    # Firewall
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };

    # TODO add nginx proxy
    # services.nginx.virtualHosts."${app}.${config.networking.domain}" = {
    #   useACMEHost = config.networking.domain;
    #   forceSSL = true;
    #   locations."^~ /" = {
    #     proxyPass = "http://${app}:${builtins.toString port}";
    #     extraConfig = "resolver 10.88.0.1;";

    #   };
    # };

    ## TODO add to homepage
    # mySystem.services.homepage.media = mkIf cfg.addToHomepage [
    #   {
    #     Plex = {
    #       icon = "${app}.svg";
    #       href = "https://${app}.${config.mySystem.domain}";

    #       description = "Media streaming service";
    #       container = "${app}";
    #       widget = {
    #         type = "tautulli";
    #         url = "https://tautulli.${config.mySystem.domain}";
    #         key = "{{HOMEPAGE_VAR_TAUTULLI__API_KEY}}";
    #       };
    #     };
    #   }
    # ];

    # TODO add gatus monitor
    # mySystem.services.gatus.monitors = [
    #   {

    #     name = app;
    #     group = "media";
    #     url = "https://${app}.${config.mySystem.domain}/web/";
    #     interval = "1m";
    #     conditions = [
    #       "[CONNECTED] == true"
    #       "[STATUS] == 200"
    #       "[RESPONSE_TIME] < 50"
    #     ];
    #   }
    # ];

    # TODO add restic backup
    # services.restic.backups = config.lib.mySystem.mkRestic {
    #   inherit app user;
    #   excludePaths = [ "Backups" ];
    #   paths = [ appFolder ];
    #   inherit appFolder;
    # };

  };
}
