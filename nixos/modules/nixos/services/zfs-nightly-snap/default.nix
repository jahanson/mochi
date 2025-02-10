{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.services.zfs-nightly-snap;

  # Replaces/Creates and mounts a ZFS snapshot
  resticSnapAndMount = pkgs.writeShellApplication {
    name = "zfs-nightly-snap";

    runtimeInputs = with pkgs; [
      busybox # for id, mount, umount, mkdir, grep, echo
      zfs # for zfs
    ];

    text = ''
      # Import our functions
      ${builtins.readFile ./functions.sh}

      BACKUP_DIRECTORY="${cfg.mountPath}"
      ZFS_DATASET="${cfg.zfsDataset}"
      SNAPSHOT_NAME="${cfg.snapshotName}"

      if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run as root."
        exit 1
      fi

      # Main logic
      zfs_backup_cleanup "$BACKUP_DIRECTORY"

      echo "Previous snapshot:"
      zfs list -t snapshot | grep "$ZFS_DATASET@$SNAPSHOT_NAME" || true

      echo "Attempting to destroy existing snapshot..."
      if zfs destroy -r "$ZFS_DATASET@$SNAPSHOT_NAME"; then
        echo "Successfully destroyed old snapshot"
      else
        echo "Failed to destroy existing snapshot"
        exit 1
      fi

      # Create new snapshot
      if ! zfs snapshot -r "$ZFS_DATASET@$SNAPSHOT_NAME"; then
        echo "Failed to create snapshot"
        exit 1
      fi

      echo "New snapshot created:"
      zfs list -t snapshot | grep "$ZFS_DATASET@$SNAPSHOT_NAME"

      if ! mount_dataset; then
        echo "Failed to mount snapshot"
        exit 1
      fi

      echo "Successfully created and mounted snapshot at $BACKUP_DIRECTORY"
      mount | grep "$BACKUP_DIRECTORY"
    '';
  };
in {
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
      default = "*-*-* 02:10:00 America/Chicago"; # Every day at 2:10 AM
      description = "When to create and mount the ZFS snapshot. Defaults to 2:10 AM.";
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
    environment.systemPackages = [resticSnapAndMount];

    systemd = {
      # Timer for nightly snapshot
      timers.zfs-nightly-snap = {
        wantedBy = ["timers.target"];
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
          PrivateMounts = "no"; # We want to mount the snapshot to the system
        };
        requires = ["zfs.target"];
        after = ["zfs.target"];
      };
    };
  };
}
