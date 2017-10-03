#!/usr/bin/env bash

set -e -x

if [ ! -d "$1" ]
then
    echo "$0 [build directory] [image file]"
    exit 1
fi
BUILD="$(realpath "$1")"

if [ -z "$2" ]
then
    echo "$0 [build directory] [image file]"
    exit 1
fi
IMAGE="$(realpath "$2")"

# Create temporary directory
DIR="$(mktemp -d)"

# Create image file
dd if=/dev/zero of="${IMAGE}" bs=1G count=2

# Partition image file
parted -s "${IMAGE}" mklabel msdos
parted -s "${IMAGE}" mkpart primary fat32 1M 100%
parted -s "${IMAGE}" set 1 boot on

# Get loopback device
LO="$(sudo losetup --find --partscan --show "${IMAGE}")"

# Format image file
sudo mkfs.fat -F 32 "${LO}p1"

# Mount image file
sudo mount "${LO}p1" "${DIR}"

# Copy data
sudo cp -rL \
  "${BUILD}/grub/efi" \
  "${BUILD}/iso/." \
  "${DIR}/"

sudo grub-install --target x86_64-efi --efi-directory "${DIR}/" --boot-directory="${DIR}/boot" --removable --recheck

sudo grub-install --target=i386-pc --boot-directory="${DIR}/boot" --recheck "${LO}"

# Unmount image file
sudo umount "${DIR}/" || sudo umount -lf "${DIR}/"

# Remove loopback
sudo losetup -d "${LO}"

# Remove temporary directory
sudo rmdir "${DIR}"
