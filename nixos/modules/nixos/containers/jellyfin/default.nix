{
  lib,
  config,
  ...
}:
with lib;
let
  app = "jellyfin";
  # renovate: depName=ghcr.io/jellyfin/jellyfin datasource=docker
  version = "10.10.2";
  image = "ghcr.io/jellyfin/jellyfin:${version}";
  port = 8096; # int
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
        "/nahar/containers/volumes/jellyfin:/config:rw"
        "/moria/media:/media:rw"
        "tmpfs:/cache:rw"
        "tmpfs:/transcode:rw"
        "tmpfs:/tmp:rw"
      ];

      environment = {
        TZ = "America/Chicago";
        DOTNET_SYSTEM_IO_DISABLEFILELOCKING = "true";
        JELLYFIN_FFmpeg__probesize = "50000000";
        JELLYFIN_FFmpeg__analyzeduration = "50000000";
      };

      ports = [ "${toString port}:${toString port}" ]; # expose port

      extraOptions = [
        "--device nvidia.com/gpu=all"
      ];
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
