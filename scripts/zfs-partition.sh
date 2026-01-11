#!/usr/bin/env bash
# ZFS disk partitioning script for Pop!_OS installation
# Creates GPT partition table with EFI System Partition and ZFS partition

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <device> [efi-size-mb]"
    echo "Example: $0 /dev/sda 512"
    exit 1
fi

DEVICE="$1"
EFI_SIZE="${2:-512}"  # Default 512MB EFI partition

echo "=== ZFS Disk Partitioning ==="
echo "Device: $DEVICE"
echo "EFI Partition Size: ${EFI_SIZE}MB"
echo ""

# Verify device exists
if [ ! -b "$DEVICE" ]; then
    echo "Error: Device $DEVICE does not exist"
    exit 1
fi

# Warn user
echo "WARNING: This will DESTROY all data on $DEVICE"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Unmount any mounted partitions
echo "Unmounting any mounted partitions on $DEVICE..."
umount ${DEVICE}* 2>/dev/null || true

# Wipe existing filesystem signatures
echo "Wiping filesystem signatures..."
wipefs --all --force "$DEVICE"

# Create GPT partition table
echo "Creating GPT partition table..."
parted -s "$DEVICE" mklabel gpt

# Create EFI System Partition (ESP)
echo "Creating EFI System Partition (${EFI_SIZE}MB)..."
parted -s "$DEVICE" mkpart primary fat32 1MiB ${EFI_SIZE}MiB
parted -s "$DEVICE" set 1 esp on

# Create ZFS partition (remainder of disk)
echo "Creating ZFS partition..."
parted -s "$DEVICE" mkpart primary ${EFI_SIZE}MiB 100%

# Wait for kernel to update partition table
sleep 2
partprobe "$DEVICE"
sleep 1

# Determine partition naming scheme
if [[ "$DEVICE" == *"nvme"* ]] || [[ "$DEVICE" == *"mmcblk"* ]]; then
    EFI_PART="${DEVICE}p1"
    ZFS_PART="${DEVICE}p2"
else
    EFI_PART="${DEVICE}1"
    ZFS_PART="${DEVICE}2"
fi

# Format EFI partition
echo "Formatting EFI partition ($EFI_PART) as FAT32..."
mkfs.vfat -F32 -n EFI "$EFI_PART"

echo ""
echo "=== Partitioning Complete ==="
echo "EFI Partition: $EFI_PART (FAT32)"
echo "ZFS Partition: $ZFS_PART (ready for ZFS pool creation)"
echo ""
echo "Export partition paths:"
echo "export EFI_PART=$EFI_PART"
echo "export ZFS_PART=$ZFS_PART"
