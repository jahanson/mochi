{
  lib,
  config,
  ...
}:
with lib;
let
  app = "scrypted";
  # renovate: depName=ghcr.io/koush/scrypted datasource=docker versioning=docker
  version = "v0.123.30-jammy-nvidia";
  image = "ghcr.io/koush/scrypted:${version}";
  port = 11080; # int
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

      volumes = [
        "/nahar/containers/volumes/scrypted:/server/volume:rw"
        # "/nahar/scrypted:/recordings:rw"
        "tmpfs:/.cache:rw"
        "tmpfs:/.npm:rw"
        "tmpfs:/tmp:rw"
      ];

      extraOptions = [
        # all usb devices, such as coral tpu
        "--device=/dev/bus/usb"
        "--network=host"
        # "--runtime=nvidia"
      ];

      environment = {
        TZ = "America/Chicago";
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
