{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  app = "plex";
  # renovate: depName=ghcr.io/onedr0p/plex datasource=docker versioning=loose
  version = "1.41.2.9200-c6bbc1b53";
  image = "ghcr.io/onedr0p/plex:${version}";
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
    # Systemd service for container
    systemd.services.${app} = {
      description = "Plex Media Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStartPre = "${pkgs.writeShellScript "scrypted-start-pre" ''
          set -o errexit
          set -o nounset
          set -o pipefail

          ${pkgs.podman}/bin/podman rm -f ${app} || true
          rm -f /run/${app}.ctr-id
        ''}";
        ExecStart = ''
          ${pkgs.podman}/bin/podman run \
            --rm \
            --name=${app} \
            --device='nvidia.com/gpu=all' \
            --log-driver=journald \
            --cidfile=/run/${app}.ctr-id \
            --cgroups=no-conmon \
            --sdnotify=conmon \
            --user=568:568 \
            --volume="/nahar/containers/volumes/plex:/config/Library/Application Support/Plex Media Server:rw" \
            --volume="/moria/media:/media:rw" \
            --volume="tmpfs:/config/Library/Application Support/Plex Media Server/Logs:rw" \
            --volume="tmpfs:/tmp:rw" \
            --env=TZ=America/Chicago \
            --env=PLEX_ADVERTISE_URL=https://10.1.1.61:32400 \
            --env=PLEX_NO_AUTH_NETWORKS=10.1.1.0/24 \
            -p 32400:32400 \
            ${image}
        '';
        ExecStop = "${pkgs.podman}/bin/podman stop --ignore --cidfile=/run/${app}.ctr-id";
        ExecStopPost = "${pkgs.podman}/bin/podman rm --force --ignore --cidfile=/run/${app}.ctr-id";
        Type = "simple";
        Restart = "always";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        32400 # Primary Plex port
      ];
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
