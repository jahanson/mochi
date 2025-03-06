{
  lib,
  config,
  ...
}:
with lib; let
  app = "scrutiny";
  # renovate: depName=AnalogJ/scrutiny datasource=github-releases
  version = "v0.8.1";
  cfg = config.mySystem.services.${app};
in {
  options.mySystem.services.${app} = {
    enable = mkEnableOption "${app}";

    # Port to expose the web ui on.
    port = mkOption {
      type = types.int;
      default = 8080;
      description = ''
        Port to expose the web ui on.
      '';
      example = 8080;
    };
    # Location where the container will store its data.
    containerVolumeLocation = mkOption {
      type = types.str;
      default = "/mnt/data/containers/${app}";
      description = ''
        The location where the container will store its data.
      '';
      example = "/mnt/data/containers/${app}";
    };

    # podman equivalent:
    # --device /dev/disk/by-id/nvme-XXXXXXXXXXXXXXXXXXXXXXXXXXXX
    devices = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Devices to monitor on Scrutiny.
      '';
      example = [
        "/dev/disk/by-id/nvme-XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      ];
    };

    # podman equivalent:
    # --cap-add SYS_RAWIO
    extraCapabilities = mkOption {
      type = types.listOf types.str;
      default = [
        "SYS_RAWIO"
      ];
      description = ''
        Extra capabilities to add to the container.
      '';
      example = [
        "SYS_RAWIO"
      ];
    };
  };

  config = mkIf cfg.enable {
    # TODO: Add automatic restarting of the container when disks.nix changes.
    # - https://github.com/nix-community/home-manager/issues/3865#issuecomment-1631998032
    # - https://github.com/NixOS/nixpkgs/blob/6f6c45b5134a8ee2e465164811e451dcb5ad86e3/nixos/modules/virtualisation/oci-containers.nix
    virtualisation.oci-containers.containers.${app} = {
      image = "ghcr.io/analogj/scrutiny:${version}-omnibus";
      autoStart = true;

      ports = [
        "${toString cfg.port}:8080" # web ui
        "8086:8086" # influxdb2
      ];

      environment = {
        TZ = "America/Chicago";
      };

      volumes = [
        "${cfg.containerVolumeLocation}:/opt/scrutiny/config"
        "${cfg.containerVolumeLocation}/influxdb2:/opt/scrutiny/influxdb"
        "/run/udev:/run/udev:ro"
      ];

      # Merge the devices and extraCapabilities into the extraOptions property
      # using the --device and --cap-add flags
      extraOptions =
        (map (disk: "--device=${toString disk}") cfg.devices)
        ++ (map (cap: "--cap-add=${cap}") cfg.extraCapabilities);
    };
  };
}
