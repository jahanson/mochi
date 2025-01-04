{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.zfs-nightly-snap;

  # Replaces/Creates and mounts a ZFS snapshot
  resticSnapAndMount = pkgs.writeShellApplication {
    name = "zfs-nightly-snap";

    runtimeInputs = with pkgs; [
      busybox # for id, mount, umount, mkdir, grep, echo
      zfs # for zfs
    ];

    text = ''
      ${builtins.readFile ./snap-and-mount.sh} "${cfg.mountPath}" "${cfg.zfsDataset}" "${cfg.snapshotName}"
    '';
  };
in
{
  options.mySystem.services.zfs-nightly-snap = {
    enable = lib.mkEnableOption "ZFS nightly snapshot service";

    mountPath = lib.mkOption {
      type = lib.types.str;
      description = "Location for the nightly snapshot mount";
      default = "/mnt/nightly_backup";
    };
    zfsDataset = lib.mkOption {
      type = lib.types.str;
      description = "Location of the dataset to be snapshot";
      default = "nahar/containers/volumes";
    };
    snapshotName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the nightly snapshot";
      default = "restic_nightly_snap";
    };
    startAt = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 02:00:00 America/Chicago"; # Every day at 2 AM
      description = "When to create and mount the ZFS snapshot. Defaults to 2 AM.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Warn if backups are disabled and machine isnt a dev box
    warnings = [
      (lib.mkIf (
        !cfg.enable && config.mySystem.purpose != "Development"
      ) "WARNING: ZFS nightly snapshot is disabled for ${config.system.name}!")
    ];

    # Adding script to system packages
    environment.systemPackages = [ resticSnapAndMount ];

    systemd = {
      # Timer for nightly snapshot
      timers.zfs-nightly-snap = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.startAt;
          Persistent = true; # Run immediately if we missed the last trigger time
        };
      };
      # Service for nightly snapshot
      services.zfs-nightly-snap = {
        description = "Create and mount nightly ZFS snapshot";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${resticSnapAndMount}/bin/zfs-nightly-snap";
        };
        requires = [ "zfs.target" ];
        after = [ "zfs.target" ];
      };
    };
  };
}
