#!/usr/bin/env bash
# ZFSBootMenu installation script for Pop!_OS
# Installs and configures ZFSBootMenu on installed system

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <root-mount-point> <efi-partition>"
    echo "Example: $0 /mnt /dev/sda1"
    exit 1
fi

ROOT_MOUNT="$1"
EFI_PART="$2"

echo "=== ZFSBootMenu Installation ==="
echo "Root mount point: $ROOT_MOUNT"
echo "EFI partition: $EFI_PART"
echo ""

# Verify mount point exists
if [ ! -d "$ROOT_MOUNT" ]; then
    echo "Error: Root mount point $ROOT_MOUNT does not exist"
    exit 1
fi

# Mount EFI partition if not already mounted
EFI_MOUNT="$ROOT_MOUNT/boot/efi"
mkdir -p "$EFI_MOUNT"

if ! mountpoint -q "$EFI_MOUNT"; then
    echo "Mounting EFI partition at $EFI_MOUNT..."
    mount "$EFI_PART" "$EFI_MOUNT"
fi

# Ensure ZFSBootMenu is installed in chroot
echo "Installing ZFSBootMenu packages..."
chroot "$ROOT_MOUNT" apt-get update
chroot "$ROOT_MOUNT" apt-get install -y --no-install-recommends \
    zfsbootmenu \
    dracut-core \
    kexec-tools \
    efibootmgr

# Create ZFSBootMenu configuration directory
mkdir -p "$ROOT_MOUNT/etc/zfsbootmenu"
mkdir -p "$ROOT_MOUNT/etc/zfsbootmenu/dracut.conf.d"

# Create ZFSBootMenu configuration
cat << 'EOF' > "$ROOT_MOUNT/etc/zfsbootmenu/config.yaml"
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
cat << 'EOF' > "$ROOT_MOUNT/etc/zfsbootmenu/dracut.conf.d/zfsbootmenu.conf"
# ZFSBootMenu dracut configuration
add_dracutmodules+=" zfsbootmenu "
omit_dracutmodules+=" network "
install_optional_items+=" /etc/zfsbootmenu/config.yaml "

# Add resume support if needed
# add_dracutmodules+=" resume "
EOF

# Create ZFSBootMenu image directory
mkdir -p "$EFI_MOUNT/EFI/zbm"

# Generate ZFSBootMenu image
echo "Generating ZFSBootMenu EFI bundle..."
chroot "$ROOT_MOUNT" /bin/bash -c "generate-zbm --config /etc/zfsbootmenu/config.yaml"

# Verify ZFSBootMenu was created
if [ ! -f "$EFI_MOUNT/EFI/zbm/vmlinuz.efi" ] && [ ! -f "$EFI_MOUNT/EFI/zbm/vmlinuz-"*".efi" ]; then
    echo "Warning: ZFSBootMenu EFI bundle not found at expected location"
    ls -la "$EFI_MOUNT/EFI/zbm/" || true
fi

# Configure EFI boot entry
echo "Configuring EFI boot entry..."

# Get the disk device from partition
if [[ "$EFI_PART" == *"nvme"* ]] || [[ "$EFI_PART" == *"mmcblk"* ]]; then
    DISK_DEVICE=$(echo "$EFI_PART" | sed 's/p[0-9]*$//')
else
    DISK_DEVICE=$(echo "$EFI_PART" | sed 's/[0-9]*$//')
fi

# Get partition number
PART_NUM=$(echo "$EFI_PART" | grep -o '[0-9]*$')

# Get first ZBM EFI file
ZBM_EFI=$(ls "$EFI_MOUNT/EFI/zbm/"*.efi | head -n 1)
if [ -n "$ZBM_EFI" ]; then
    ZBM_EFI_NAME=$(basename "$ZBM_EFI")
    
    # Create EFI boot entry
    chroot "$ROOT_MOUNT" efibootmgr --create \
        --disk "$DISK_DEVICE" \
        --part "$PART_NUM" \
        --label "ZFSBootMenu" \
        --loader "\\EFI\\zbm\\$ZBM_EFI_NAME" || {
        echo "Warning: Failed to create EFI boot entry. Manual configuration may be needed."
    }
fi

# Create a post-kernel-install hook to regenerate ZFSBootMenu
cat << 'EOF' > "$ROOT_MOUNT/etc/kernel/postinst.d/zz-update-zbm"
#!/bin/bash
# Regenerate ZFSBootMenu after kernel installation
set -e
generate-zbm --config /etc/zfsbootmenu/config.yaml
EOF

chmod +x "$ROOT_MOUNT/etc/kernel/postinst.d/zz-update-zbm"

echo ""
echo "=== ZFSBootMenu Installation Complete ==="
echo "EFI boot entries:"
chroot "$ROOT_MOUNT" efibootmgr -v | grep -i zbm || echo "No ZFSBootMenu entry found"
echo ""
echo "ZFSBootMenu files:"
ls -lh "$EFI_MOUNT/EFI/zbm/"
