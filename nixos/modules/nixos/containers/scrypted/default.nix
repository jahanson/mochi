{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  app = "scrypted";
  # renovate: depName=ghcr.io/koush/scrypted datasource=docker versioning=docker
  version = "v0.138.12-noble-nvidia";
  image = "ghcr.io/koush/scrypted:${version}";
  cfg = config.mySystem.containers.${app};
in {
  # Options
  options.mySystem.containers.${app} = {
    enable = mkEnableOption "${app}";
    # TODO add to homepage
    # addToHomepage = mkEnableOption "Add ${app} to homepage" // {
    #   default = true;
    # };
    openFirewall =
      mkEnableOption "Open firewall for ${app}"
      // {
        default = true;
      };
  };

  # Implementation
  config = mkIf cfg.enable {
    # Systemd service for container
    systemd.services.${app} = {
      description = "Scrypted Home Security";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

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
            --device=/dev/bus/usb \
            --device='nvidia.com/gpu=all' \
            --log-driver=journald \
            --cidfile=/run/${app}.ctr-id \
            --cgroups=no-conmon \
            --sdnotify=conmon \
            --volume="/nahar/containers/volumes/scrypted:/server/volume:rw" \
            --volume="/nahar/scrypted/:/recordings:rw" \
            --volume="tmpfs:/.cache:rw" \
            --volume="tmpfs:/.npm:rw" \
            --volume="tmpfs:/tmp:rw" \
            --env=TZ=America/Chicago \
            --env=LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64 \
            --network=host \
            ${image}
        '';
        ExecStop = "${pkgs.podman}/bin/podman stop --ignore --cidfile=/run/${app}.ctr-id";
        ExecStopPost = "${pkgs.podman}/bin/podman rm --force --ignore --cidfile=/run/${app}.ctr-id";
        Type = "simple";
        Restart = "always";
      };
    };

    # Firewall
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        11080 # Main Scrypted interface
        10443 # HTTPS interface
        8554 # RTSP server
        33961 # Homekit
      ];
      allowedUDPPorts = [
        10443 # HTTPS interface
        8554 # RTSP server
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
