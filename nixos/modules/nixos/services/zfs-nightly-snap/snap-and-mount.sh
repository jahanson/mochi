#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=/etc/nix/inputs/nixpkgs -i bash -p busybox zfs
# shellcheck disable=SC1008

set -e # Exit on error

# Source the functions
. ./functions.sh

BACKUP_DIRECTORY="${1:-/mnt/restic_nightly_backup}"
ZFS_DATASET="${2:-nahar/containers/volumes}"
SNAPSHOT_NAME="${3:-restic_nightly_snap}"

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
