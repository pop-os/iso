#!/usr/bin/env bash
# ZFS pool and dataset creation script for Pop!_OS
# Creates encrypted ZFS pool with recommended dataset layout

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <zfs-partition> <pool-name> [encryption-passphrase]"
    echo "Example: $0 /dev/sda2 rpool"
    echo "If passphrase is not provided, will prompt for it"
    exit 1
fi

ZFS_PART="$1"
POOL_NAME="$2"
PASSPHRASE="$3"

echo "=== ZFS Pool Creation ==="
echo "Partition: $ZFS_PART"
echo "Pool Name: $POOL_NAME"
echo ""

# Verify partition exists
if [ ! -b "$ZFS_PART" ]; then
    echo "Error: Partition $ZFS_PART does not exist"
    exit 1
fi

# Check if pool already exists
if zpool list "$POOL_NAME" > /dev/null 2>&1; then
    echo "Error: Pool $POOL_NAME already exists"
    exit 1
fi

# Setup encryption
ENCRYPTION_OPTS=""
if [ -n "$PASSPHRASE" ]; then
    echo "$PASSPHRASE" > /tmp/zfs-passphrase
    ENCRYPTION_OPTS="-O encryption=aes-256-gcm -O keylocation=file:///tmp/zfs-passphrase -O keyformat=passphrase"
else
    echo "Encryption will be configured interactively"
    ENCRYPTION_OPTS="-O encryption=aes-256-gcm -O keylocation=prompt -O keyformat=passphrase"
fi

# Create the pool with optimal settings for root filesystem
echo "Creating ZFS pool $POOL_NAME..."
zpool create \
    -f \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O compression=lz4 \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=none \
    $ENCRYPTION_OPTS \
    "$POOL_NAME" "$ZFS_PART"

# Clean up temporary passphrase file
rm -f /tmp/zfs-passphrase

echo "Pool $POOL_NAME created successfully"
echo ""

# Create dataset layout
echo "Creating dataset layout..."

# Root dataset container
zfs create -o mountpoint=none "$POOL_NAME/ROOT"

# Boot environment (root filesystem)
zfs create -o mountpoint=/ -o canmount=noauto "$POOL_NAME/ROOT/pop"

# Set boot filesystem
zpool set bootfs="$POOL_NAME/ROOT/pop" "$POOL_NAME"

# Set ZFSBootMenu properties on root dataset
zfs set org.zfsbootmenu:commandline="quiet splash" "$POOL_NAME/ROOT/pop"
zfs set org.zfsbootmenu:active=on "$POOL_NAME/ROOT/pop"

# User data container
zfs create -o mountpoint=none "$POOL_NAME/USERDATA"

# Home directory
zfs create -o mountpoint=/home "$POOL_NAME/USERDATA/home"

# Variable data container
zfs create -o mountpoint=none "$POOL_NAME/var"

# Cache (excluded from snapshots)
zfs create -o mountpoint=/var/cache -o com.sun:auto-snapshot=false "$POOL_NAME/var/cache"

# Logs (separate snapshot policy)
zfs create -o mountpoint=/var/log "$POOL_NAME/var/log"

# Tmp (no snapshots)
zfs create -o mountpoint=/var/tmp -o com.sun:auto-snapshot=false "$POOL_NAME/var/tmp"

# Reserved space (10% for deletions and emergencies)
zfs create -o mountpoint=none -o reservation=10% "$POOL_NAME/reserved"

echo ""
echo "=== ZFS Pool Layout Created ==="
zfs list -r "$POOL_NAME"
echo ""
echo "Pool properties:"
zpool get all "$POOL_NAME" | grep -E "bootfs|ashift|autotrim"
echo ""
echo "Root dataset properties:"
zfs get all "$POOL_NAME/ROOT/pop" | grep -E "mountpoint|canmount|encryption|org.zfsbootmenu"
