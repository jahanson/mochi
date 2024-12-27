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
      # Check if running as root
      if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run as root."
        exit 1
      fi

      BACKUP_DIRECTORY="${cfg.mountPath}"
      ZFS_DATASET="${cfg.zfsDataset}"
      SNAPSHOT_NAME="${cfg.snapshotName}"

      # functions sourced from: https://github.com/Jip-Hop/zfs-backup-snapshots
      # some enhancements made to the original code to adhere to best practices
      # mounts all zfs filesystems under $ZFS_DATASET
      function mount_dataset() {
        # ensure BACKUP_DIRECTORY exists
        mkdir -p "$BACKUP_DIRECTORY"
        # get list of all zfs filesystems under $ZFS_DATASET
        # exclude if mountpoint "legacy" and "none" mountpoint
        # order by shallowest mountpoint first (determined by number of slashes)
        mapfile -t fs < <(zfs list "$ZFS_DATASET" -r -H -o name,mountpoint | grep -E "(legacy)$|(none)$" -v | awk '{print gsub("/","/", $2), $1}' | sort -n | cut -d' ' -f2-)

        for fs in "''${fs[@]}"; do
          mount_latest_snap "''${fs}" "$BACKUP_DIRECTORY"
        done
        return 0
      }

      # umounts and cleans up the backup directory
      # usage: zfs_backup_cleanup BACKUP_DIRECTORY
      function zfs_backup_cleanup() {
        # get all filesystems mounted within the backup directory
        mapfile -t fs < <(tac /etc/mtab | cut -d " " -f 2 | grep "''${1}")

        # umount said filesystems
        for i in "''${fs[@]}"; do
          echo "Unmounting $i"
          umount "$i"
        done

        # delete empty directories from within the backup directory
        find "''${1}" -type d -empty -delete
      }

      # gets the name of the newest snapshot given a zfs filesystem
      # usage: get_latest_snap filesystem
      function zfs_latest_snap() {
        snapshot=$(zfs list -H -t snapshot -o name -S creation -d1 "''${1}" | head -1 | cut -d '@' -f 2)
        if [[ -z $snapshot ]]; then
          # if there's no snapshot then let's ignore it
          echo "No snapshot exists for ''${1}, it will not be backed up."
          return 1
        fi
        echo "$snapshot"
      }

      # gets the path of a snapshot given a zfs filesystem and a snapshot name
      # usage zfs_snapshot_mountpoint filesystem snapshot
      function zfs_snapshot_mountpoint() {
        # get mountpoint for filesystem
        mountpoint=$(zfs list -H -o mountpoint "''${1}")

        # exit if filesystem doesn't exist
        if [[ $? == 1 ]]; then
          return 1
        fi

        # build out path
        path="''${mountpoint}/.zfs/snapshot/''${2}"

        # check to make sure path exists
        if stat "''${path}" &> /dev/null; then
          echo "''${path}"
          return 0
        else
          return 1
        fi
      }

      # mounts latest snapshot in directory
      # usage: mount_latest_snap filesystem BACKUP_DIRECTORY
      function mount_latest_snap() {
        local mount_point="''${2}"
        local filesystem="''${1}"

        # get name of latest snapshot
        snapshot=$(zfs_latest_snap "''${filesystem}")

        # if there's no snapshot then let's ignore it
        if [[ $? == 1 ]]; then
          echo "No snapshot exists for ''${filesystem}, it will not be backed up."
          return 1
        fi

        sourcepath=$(zfs_snapshot_mountpoint "''${filesystem}" "''${snapshot}")
        # if the filesystem is not mounted/path doesn't exist then let's ignore as well
        if [[ $? == 1 ]]; then
          echo "Cannot find snapshot ''${snapshot} for ''${filesystem}, perhaps it's not mounted? Anyways, it will not be backed up."
          return 1
        fi

        # mountpath may be inside a previously mounted snapshot
        mountpath="$mount_point/''${filesystem}"

        # mount to backup directory using a bind filesystem
        mkdir -p "''${mountpath}"
        echo "mount ''${sourcepath} => ''${mountpath}"
        mount --bind --read-only "''${sourcepath}" "''${mountpath}"
        return 0
      }

      # Unmount and cleanup if necessary
      zfs_backup_cleanup "$BACKUP_DIRECTORY"

      # Check if snapshot exists
      echo "Previous snapshot:"
      zfs list -t snapshot | grep "$ZFS_DATASET@$SNAPSHOT_NAME" || true

      # Attempt to destroy existing snapshot
      echo "Attempting to destroy existing snapshot..."
      if zfs list -t snapshot | grep -q "$ZFS_DATASET@$SNAPSHOT_NAME"; then
        if zfs destroy -r "$ZFS_DATASET@$SNAPSHOT_NAME"; then
          echo "Successfully destroyed old snapshot"
        else
          echo "Failed to destroy existing snapshot"
          exit 1
        fi
      else
        echo "No existing snapshot found"
      fi

      # Create new snapshot
      if ! zfs snapshot -r "$ZFS_DATASET@$SNAPSHOT_NAME"; then
        echo "Failed to create snapshot"
        exit 1
      fi

      echo "New snapshot created:"
      zfs list -t snapshot | grep "$ZFS_DATASET@$SNAPSHOT_NAME"

      # Mount the snapshot
      if ! mount_dataset; then
        echo "Failed to mount snapshot"
        exit 1
      fi

      echo "Successfully created and mounted snapshot at $BACKUP_DIRECTORY"
      mount | grep "$BACKUP_DIRECTORY"
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
          ExecStart = "${lib.getExe resticSnapAndMount}";
        };
        requires = [ "zfs.target" ];
        after = [ "zfs.target" ];
      };
    };
  };
}
