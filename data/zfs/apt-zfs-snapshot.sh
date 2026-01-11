#!/usr/bin/env bash
# APT ZFS snapshot helper script
# This script creates snapshots before APT operations
# Install to: /usr/local/bin/apt-zfs-snapshot

set -e

ACTION="${1:-pre}"
POOL_NAME="${ZFS_POOL:-rpool}"
ROOT_DATASET="$POOL_NAME/ROOT/pop"
SNAPSHOT_PREFIX="apt"

# Only run if ZFS is available
if ! command -v zfs > /dev/null 2>&1; then
    exit 0
fi

# Check if root dataset exists
if ! zfs list "$ROOT_DATASET" > /dev/null 2>&1; then
    exit 0
fi

case "$ACTION" in
    pre)
        # Create snapshot before APT operation
        TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
        SNAPSHOT_NAME="${ROOT_DATASET}@${SNAPSHOT_PREFIX}_${TIMESTAMP}"
        
        # Only create snapshot if packages are being modified
        if [ -t 0 ]; then
            # stdin is a terminal, might be an interactive operation
            echo "Creating ZFS snapshot: $SNAPSHOT_NAME"
        fi
        
        zfs snapshot -r "$SNAPSHOT_NAME" || true
        
        # Store snapshot name for post-hook
        echo "$SNAPSHOT_NAME" > /tmp/.apt-zfs-snapshot
        ;;
        
    post)
        # Post-operation: could be used for cleanup or verification
        # For now, we keep the snapshot for potential rollback
        if [ -f /tmp/.apt-zfs-snapshot ]; then
            rm -f /tmp/.apt-zfs-snapshot
        fi
        ;;
        
    *)
        echo "Usage: $0 {pre|post}"
        exit 1
        ;;
esac

exit 0
