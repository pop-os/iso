#!/usr/bin/env bash
# ZFS pool and dataset creation script for Pop!_OS
# Creates ZFS pool on LUKS-encrypted device (or raw device)
# LUKS encryption is handled BEFORE this script runs

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <device> <pool-name>"
    echo "Example: $0 /dev/mapper/cryptroot rpool"
    echo "Example: $0 /dev/sda2 rpool  (unencrypted)"
    echo ""
    echo "NOTE: For LUKS encryption, run cryptsetup BEFORE this script"
    echo "      and pass the /dev/mapper/cryptroot device."
    exit 1
fi

ZFS_DEVICE="$1"
POOL_NAME="$2"

echo "=== ZFS Pool Creation ==="
echo "Device: $ZFS_DEVICE"
echo "Pool Name: $POOL_NAME"
echo ""

# Verify device exists
if [ ! -b "$ZFS_DEVICE" ]; then
    echo "Error: Device $ZFS_DEVICE does not exist"
    exit 1
fi

# Check if pool already exists
if zpool list "$POOL_NAME" > /dev/null 2>&1; then
    echo "Error: Pool $POOL_NAME already exists"
    exit 1
fi

# Create the pool WITHOUT ZFS native encryption
# LUKS handles encryption at the block layer
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
    "$POOL_NAME" "$ZFS_DEVICE"

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

# Reserved space for deletions and emergencies
zfs create -o mountpoint=none -o refreservation=1G "$POOL_NAME/reserved"

echo ""
echo "=== ZFS Pool Layout Created ==="
zfs list -r "$POOL_NAME"
echo ""
echo "Pool properties:"
zpool get all "$POOL_NAME" | grep -E "bootfs|ashift|autotrim"
echo ""
echo "Root dataset properties:"
zfs get all "$POOL_NAME/ROOT/pop" | grep -E "mountpoint|canmount|org.zfsbootmenu"
