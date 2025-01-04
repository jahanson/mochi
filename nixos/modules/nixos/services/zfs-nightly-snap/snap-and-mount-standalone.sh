#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=/etc/nix/inputs/nixpkgs -i bash -p busybox zfs
# shellcheck disable=SC1008

set -e # Exit on error

BACKUP_DIRECTORY="/mnt/restic_nightly_backup"
ZFS_DATASET="nahar/containers/volumes"
SNAPSHOT_NAME="restic_nightly_snap"

# Execute the main script with our parameters
./snap-and-mount.sh \
  "$BACKUP_DIRECTORY" \
  "$ZFS_DATASET" \
  "$SNAPSHOT_NAME"
