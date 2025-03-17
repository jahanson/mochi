{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  app = "jellyseerr";
  cfg = config.mySystem.containers.${app};
  group = "kah";
  image = "ghcr.io/fallenbagel/jellyseerr:${version}";
  user = "jellyseerr";
  # renovate: depName=ghcr.io/fallenbagel/jellyseerr datasource=docker
  version = "2.5.1";
  volumeLocation = "/nahar/containers/volumes/jellyseerr";
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
    # User configuration
    users = mkIf (user == "jellyseerr") {
      users.jellyseerr = {
        inherit group;
        isSystemUser = true;
      };
    };

    # Systemd service for container
    systemd.services.${app} = {
      description = "Jellyseerr media request and discovery manager for Jellyfin";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        ExecStartPre = "${pkgs.writeShellScript "jellyseerr-start-pre" ''
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
            --log-driver=journald \
            --cidfile=/run/${app}.ctr-id \
            --cgroups=no-conmon \
            --sdnotify=conmon \
            --volume="${volumeLocation}:/app/config:rw" \
            --volume="/moria/media:/media:rw" \
            --volume="tmpfs:/cache:rw" \
            --volume="tmpfs:/transcode:rw" \
            --volume="tmpfs:/tmp:rw" \
            --env=TZ=America/Chicago \
            -p 5055:5055 \
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
        5055 # HTTP web interface
      ];
    };
  };
}
