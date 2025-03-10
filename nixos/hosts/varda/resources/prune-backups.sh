# Set the backup directory
BACKUP_DIR="/mnt/storagebox/forgejo/backup"

KEEP_NUM=7

echo "Starting backup cleanup process..."
echo "Keeping the $KEEP_NUM most recent backups in $BACKUP_DIR"

# Find all backup files, sort by modification time (newest first),
# skip the first KEEP_NUM, and delete the rest
find "$BACKUP_DIR" -type f -name "forgejo-dump-*" -print0 |
  sort -z -t_ -k2 -r |
  tail -z -n +$((KEEP_NUM + 1)) |
  while IFS= read -r -d '' file; do
    echo "Deleting: $file"
    rm -f "$file"
  done

echo "Cleanup complete. Deleted all but the $KEEP_NUM most recent backups."
