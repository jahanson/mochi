# functions sourced from: https://github.com/Jip-Hop/zfs-backup-snapshots
function mount_dataset() {
  mkdir -p "$BACKUP_DIRECTORY"
  mapfile -t fs < <(zfs list "$ZFS_DATASET" -r -H -o name,mountpoint | grep -E "(legacy)$|(none)$" -v | awk '{print gsub("/","/", $2), $1}' | sort -n | cut -d' ' -f2-)

  for fs in "${fs[@]}"; do
    mount_latest_snap "${fs}" "${BACKUP_DIRECTORY}"
  done
  return 0
}

function zfs_backup_cleanup() {
  mapfile -t fs < <(tac /etc/mtab | cut -d " " -f 2 | grep "${1}")

  for i in "${fs[@]}"; do
    echo "Unmounting $i"
    umount "$i"
  done

  find "${1}" -type d -empty -delete 2>/dev/null || true
}

function zfs_latest_snap() {
  snapshot=$(zfs list -H -t snapshot -o name -S creation -d1 "${1}" | head -1 | cut -d '@' -f 2)
  if [[ -z $snapshot ]]; then
    echo "No snapshot exists for ${1}, it will not be backed up."
    return 1
  fi
  echo "$snapshot"
}

function zfs_snapshot_mountpoint() {
  mountpoint=$(zfs list -H -o mountpoint "${1}")
  if [[ $? == 1 ]]; then
    return 1
  fi
  path="${mountpoint}/.zfs/snapshot/${2}"
  if stat "${path}" &>/dev/null; then
    echo "${path}"
    return 0
  else
    return 1
  fi
}

function mount_latest_snap() {
  BACKUP_DIRECTORY="${2}"
  filesystem="${1}"

  snapshot=$(zfs_latest_snap "${filesystem}")
  if [[ $? == 1 ]]; then
    return 1
  fi

  sourcepath=$(zfs_snapshot_mountpoint "${filesystem}" "${snapshot}")
  if [[ $? == 1 ]]; then
    echo "Cannot find snapshot ${snapshot} for ${filesystem}, perhaps it's not mounted?"
    return 1
  fi

  mountpath=${BACKUP_DIRECTORY}/${filesystem}
  mkdir -p "${mountpath}"
  echo "mount ${sourcepath} => ${mountpath}"
  mount --bind --read-only "${sourcepath}" "${mountpath}"
  return 0
}
