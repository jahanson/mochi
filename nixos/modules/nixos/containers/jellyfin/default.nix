{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  app = "jellyfin";
  cfg = config.mySystem.containers.${app};
  group = "kah";
  image = "ghcr.io/jellyfin/jellyfin:${version}";
  user = "kah";
  # renovate: depName=ghcr.io/jellyfin/jellyfin datasource=docker
  version = "10.10.6";
  volumeLocation = "/nahar/containers/volumes/jellyfin";
in {
  # Options
  options.mySystem.containers.${app} = {
    enable = mkEnableOption "${app}";
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
      description = "Jellyfin Media Server";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        ExecStartPre = "${pkgs.writeShellScript "jellyfin-start-pre" ''
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
            --user="${toString config.users.users."${user}".uid}:${
            toString config.users.groups."${group}".gid
          }" \
            --device='nvidia.com/gpu=all' \
            --log-driver=journald \
            --cidfile=/run/${app}.ctr-id \
            --cgroups=no-conmon \
            --sdnotify=conmon \
            --volume="${volumeLocation}:/config:rw" \
            --volume="/moria/media:/media:rw" \
            --volume="tmpfs:/cache:rw" \
            --volume="tmpfs:/transcode:rw" \
            --volume="tmpfs:/tmp:rw" \
            --env=TZ=America/Chicago \
            --env=DOTNET_SYSTEM_IO_DISABLEFILELOCKING=true \
            --env=JELLYFIN_FFmpeg__probesize=50000000 \
            --env=JELLYFIN_FFmpeg__analyzeduration=50000000 \
            --env=JELLYFIN_PublishedServerUrl=http://10.1.1.61:8096 \
            -p 8096:8096 \
            -p 8920:8920 \
            -p 1900:1900/udp \
            -p 7359:7359/udp \
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
        8096 # HTTP web interface
        8920 # HTTPS web interface
      ];
      allowedUDPPorts = [
        1900 # DLNA discovery
        7359 # Jellyfin auto-discovery
      ];
    };

    sops.secrets = {
      "restic/jellyfin/env" = {
        inherit group;
        sopsFile = ./secrets.sops.yaml;
        owner = user;
        mode = "0400";
      };
      "restic/jellyfin/password" = {
        inherit group;
        sopsFile = ./secrets.sops.yaml;
        owner = user;
        mode = "0400";
      };
      "restic/jellyfin/template" = {
        inherit group;
        sopsFile = ./secrets.sops.yaml;
        owner = user;
        mode = "0400";
      };
    };

    # Restic backups for `jellyfin-local` and `jellyfin-remote`
    services.restic.backups = config.lib.mySystem.mkRestic {
      inherit app user;
      environmentFile = config.sops.secrets."restic/jellyfin/env".path;
      excludePaths = [];
      localResticTemplate = "/eru/restic/jellyfin";
      passwordFile = config.sops.secrets."restic/jellyfin/password".path;
      paths = [volumeLocation];
      remoteResticTemplateFile = config.sops.secrets."restic/jellyfin/template".path;
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
  };
}
