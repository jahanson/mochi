# shellcheck disable=SC1008

# Command line arguments
BACKUP_DIRECTORY="$1"
ZFS_DATASET="$2"
SNAPSHOT_NAME="$3"

if [ -z "$BACKUP_DIRECTORY" ] || [ -z "$ZFS_DATASET" ] || [ -z "$SNAPSHOT_NAME" ]; then
  echo "Usage: $0 <backup_directory> <zfs_dataset> <snapshot_name>"
  exit 1
fi
# Check if running as root

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

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

  for fs in "${fs[@]}"; do
    mount_latest_snap "${fs}" "${BACKUP_DIRECTORY}"
  done
  return 0
}

# umounts and cleans up the backup directory
# usage: zfs_backup_cleanup BACKUP_DIRECTORY
function zfs_backup_cleanup() {
  # get all filesystems mounted within the backup directory
  mapfile -t fs < <(tac /etc/mtab | cut -d " " -f 2 | grep "${1}")

  # umount said filesystems
  for i in "${fs[@]}"; do
    echo "Unmounting $i"
    umount "$i"
  done

  # delete empty directories from within the backup directory
  find "${1}" -type d -empty -delete 2>/dev/null || true
}

# gets the name of the newest snapshot given a zfs filesystem
# usage: get_latest_snap filesystem
function zfs_latest_snap() {
  snapshot=$(zfs list -H -t snapshot -o name -S creation -d1 "${1}" | head -1 | cut -d '@' -f 2)
  if [[ -z $snapshot ]]; then
    # if there's no snapshot then let's ignore it
    echo "No snapshot exists for ${1}, it will not be backed up."
    return 1
  fi
  echo "$snapshot"
}

# gets the path of a snapshot given a zfs filesystem and a snapshot name
# usage zfs_snapshot_mountpoint filesystem snapshot
function zfs_snapshot_mountpoint() {
  # get mountpoint for filesystem
  mountpoint=$(zfs list -H -o mountpoint "${1}")

  # exit if filesystem doesn't exist
  if [[ $? == 1 ]]; then
    return 1
  fi

  # build out path
  path="${mountpoint}/.zfs/snapshot/${2}"

  # check to make sure path exists
  if stat "${path}" &>/dev/null; then
    echo "${path}"
    return 0
  else
    return 1
  fi
}

# mounts latest snapshot in directory
# usage: mount_latest_snap filesystem BACKUP_DIRECTORY
function mount_latest_snap() {
  BACKUP_DIRECTORY="${2}"
  filesystem="${1}"

  # get name of latest snapshot
  snapshot=$(zfs_latest_snap "${filesystem}")

  # if there's no snapshot then let's ignore it
  if [[ $? == 1 ]]; then
    echo "No snapshot exists for ${filesystem}, it will not be backed up."
    return 1
  fi

  sourcepath=$(zfs_snapshot_mountpoint "${filesystem}" "${snapshot}")
  # if the filesystem is not mounted/path doesn't exist then let's ignore as well
  if [[ $? == 1 ]]; then
    echo "Cannot find snapshot ${snapshot} for ${filesystem}, perhaps it's not mounted? Anyways, it will not be backed up."
    return 1
  fi

  # mountpath may be inside a previously mounted snapshot
  mountpath=${BACKUP_DIRECTORY}/${filesystem}

  # mount to backup directory using a bind filesystem
  mkdir -p "${mountpath}"
  echo "mount ${sourcepath} => ${mountpath}"
  mount --bind --read-only "${sourcepath}" "${mountpath}"
  return 0
}

# Unmount and cleanup if necessary
zfs_backup_cleanup "$BACKUP_DIRECTORY"

# Check if snapshot exists
echo "Previous snapshot:"
zfs list -t snapshot | grep "$ZFS_DATASET@$SNAPSHOT_NAME" || true

# Attempt to destroy existing snapshot
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

# Mount the snapshot
if ! mount_dataset; then
  echo "Failed to mount snapshot"
  exit 1
fi

echo "Successfully created and mounted snapshot at $BACKUP_DIRECTORY"
mount | grep "$BACKUP_DIRECTORY"
