#!/usr/bin/env bash
# Setup ZFS support in Pop!_OS live environment
# This script ensures ZFS modules are loaded and pools can be imported

set -e -x

export DEBIAN_FRONTEND=noninteractive

echo "Setting up ZFS support in live environment..."

# Load ZFS kernel module
if ! lsmod | grep -q zfs; then
    echo "Loading ZFS kernel module..."
    modprobe zfs || {
        echo "Warning: Failed to load ZFS module. ZFS support may not be available."
        exit 0
    }
fi

# Verify ZFS is working
if command -v zpool > /dev/null 2>&1; then
    echo "ZFS utilities found"
    zpool version || true
    zfs version || true
else
    echo "Warning: ZFS utilities not found"
    exit 0
fi

# Create ZFS cache directory
mkdir -p /etc/zfs

# Set up ZFS event daemon
if [ -f /lib/systemd/system/zfs-zed.service ]; then
    systemctl enable zfs-zed.service || true
    systemctl start zfs-zed.service || true
fi

# Import existing pools (if any) for recovery purposes
echo "Scanning for existing ZFS pools..."
zpool import -a -N -f || {
    echo "No existing ZFS pools found or import failed (this is normal for fresh installs)"
}

# List any imported pools
zpool list || echo "No ZFS pools currently imported"

echo "ZFS live environment setup complete"
