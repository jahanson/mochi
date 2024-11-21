{
  lib,
  config,
  ...
}:
with lib;
let
  app = "plex";
  # renovate: depName=ghcr.io/onedr0p/plex datasource=docker versioning=loose
  version = "1.41.2.9200-c6bbc1b53";
  image = "ghcr.io/onedr0p/plex:${version}";
  port = 32400; # int
  cfg = config.mySystem.containers.${app};
in
{
  # Options
  options.mySystem.containers.${app} = {
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
        "/nahar/containers/volumes/plex:/config/Library/Application Support/Plex Media Server:rw"
        "/moria/media:/media:rw"
        "tmpfs:/config/Library/Application Support/Plex Media Server/Logs:rw"
        "tmpfs:/tmp:rw"
      ];

      extraOptions = [
        "--runtime=nvidia"
      ];

      environment = {
        TZ = "America/Chicago";
        # PLEX_ADVERTISE_URL = "https://${app}.hsn.dev";
        PLEX_NO_AUTH_NETWORKS = "10.1.1.0/24,10.1.2.0/24";
      };

      ports = [ "${toString port}:${toString port}" ]; # expose port
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
