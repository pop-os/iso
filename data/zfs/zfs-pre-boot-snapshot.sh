#!/usr/bin/env bash
# Create a ZFS snapshot before system reboot
# Install to: /usr/local/bin/zfs-pre-boot-snapshot

set -e

POOL_NAME="${ZFS_POOL:-rpool}"
ROOT_DATASET="$POOL_NAME/ROOT/pop"
SNAPSHOT_PREFIX="pre-boot"

# Only run if ZFS is available
if ! command -v zfs > /dev/null 2>&1; then
    exit 0
fi

# Check if root dataset exists
if ! zfs list "$ROOT_DATASET" > /dev/null 2>&1; then
    exit 0
fi

# Create snapshot
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
SNAPSHOT_NAME="${ROOT_DATASET}@${SNAPSHOT_PREFIX}_${TIMESTAMP}"

echo "Creating pre-boot ZFS snapshot: $SNAPSHOT_NAME"
zfs snapshot -r "$SNAPSHOT_NAME"

# Keep only last 5 pre-boot snapshots
SNAPSHOTS=$(zfs list -H -t snapshot -o name -S creation "$ROOT_DATASET" | grep "@${SNAPSHOT_PREFIX}_" | tail -n +6)

if [ -n "$SNAPSHOTS" ]; then
    echo "Pruning old pre-boot snapshots..."
    echo "$SNAPSHOTS" | while read -r snap; do
        echo "  Removing: $snap"
        zfs destroy -r "$snap" || true
    done
fi

exit 0
