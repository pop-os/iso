#!/usr/bin/env bash
# Build ZFSBootMenu EFI bundle for Pop!_OS ISO
# This script generates the ZFSBootMenu EFI executable that will be used
# for booting ZFS root filesystems

set -e -x

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 [chroot directory] [output directory]"
    exit 1
fi

CHROOT="$(realpath "$1")"
OUTPUT_DIR="$(realpath "$2")"

echo "Building ZFSBootMenu EFI bundle in $CHROOT"
echo "Output directory: $OUTPUT_DIR"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Check if chroot has necessary tools
if ! sudo chroot "$CHROOT" which generate-zbm > /dev/null 2>&1; then
    echo "Installing ZFSBootMenu in chroot..."
    sudo chroot "$CHROOT" apt-get update
    sudo chroot "$CHROOT" apt-get install -y --no-install-recommends \
        zfsbootmenu \
        dracut-core \
        kexec-tools
fi

# Create ZFSBootMenu configuration directory
sudo mkdir -p "$CHROOT/etc/zfsbootmenu"
sudo mkdir -p "$CHROOT/etc/zfsbootmenu/dracut.conf.d"

# Create temporary ZFSBootMenu configuration for ISO build
cat << 'EOF' | sudo tee "$CHROOT/etc/zfsbootmenu/config.yaml" > /dev/null
Global:
  ManageImages: true
  BootMountPoint: /boot/efi
  DracutConfDir: /etc/zfsbootmenu/dracut.conf.d

Components:
  Enabled: false

EFI:
  ImageDir: /boot/efi/EFI/zbm
  Versions: 2
  Enabled: true

Kernel:
  CommandLine: quiet splash
EOF

# Create dracut configuration for ZFSBootMenu
cat << 'EOF' | sudo tee "$CHROOT/etc/zfsbootmenu/dracut.conf.d/zfsbootmenu.conf" > /dev/null
# ZFSBootMenu dracut configuration
add_dracutmodules+=" zfsbootmenu "
omit_dracutmodules+=" network "
install_optional_items+=" /etc/zfsbootmenu/config.yaml "
EOF

# Generate ZFSBootMenu image
echo "Generating ZFSBootMenu EFI bundle..."
sudo chroot "$CHROOT" /bin/bash -c "
    mkdir -p /boot/efi/EFI/zbm
    generate-zbm --config /etc/zfsbootmenu/config.yaml
"

# Copy generated EFI bundle to output directory
if [ -d "$CHROOT/boot/efi/EFI/zbm" ]; then
    sudo cp -v "$CHROOT/boot/efi/EFI/zbm/"*.efi "$OUTPUT_DIR/" || true
    echo "ZFSBootMenu EFI bundle built successfully"
else
    echo "Warning: ZFSBootMenu EFI bundle not found at expected location"
fi

# Clean up
sudo rm -f "$CHROOT/etc/zfsbootmenu/config.yaml"
sudo rm -f "$CHROOT/etc/zfsbootmenu/dracut.conf.d/zfsbootmenu.conf"

echo "ZFSBootMenu build complete"
