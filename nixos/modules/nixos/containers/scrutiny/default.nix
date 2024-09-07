{ lib, config, ... }:
with lib;
let
  app = "scrutiny";
  # renovate: depName=AnalogJ/scrutiny datasource=github-releases
  version = "v0.8.1";
  cfg = config.mySystem.services.${app};
in
{
  options.mySystem.services.${app} = {
    enable = mkEnableOption "${app}";

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
      default = [ ];
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
    virtualisation.oci-containers.containers.${app} = {
      image = "ghcr.io/analogj/scrutiny:${version}-omnibus";
      autoStart = true;

      ports = [
        "8585:8585" # web ui
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
        ++
        (map (cap: "--cap-add=${cap}") cfg.extraCapabilities);
    };
  };
}
