#!/usr/bin/env bash
# Main ZFS installation script for Pop!_OS
# Orchestrates the complete ZFS installation process

set -e

# Configuration defaults
POOL_NAME="${POOL_NAME:-rpool}"
EFI_SIZE="${EFI_SIZE:-512}"
ROOT_MOUNT="${ROOT_MOUNT:-/mnt}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root"
    exit 1
fi

# Check if required tools are available
for tool in zpool zfs parted mkfs.vfat efibootmgr; do
    if ! command -v "$tool" > /dev/null 2>&1; then
        error "Required tool '$tool' not found. Please install ZFS utilities."
        exit 1
    fi
done

info "==================================================="
info "Pop!_OS ZFS Installation Script"
info "==================================================="
echo ""

# Step 1: Device selection
if [ -z "$DEVICE" ]; then
    echo "Available devices:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL
    echo ""
    read -p "Enter device to install to (e.g., /dev/sda): " DEVICE
fi

if [ ! -b "$DEVICE" ]; then
    error "Device $DEVICE does not exist"
    exit 1
fi

info "Installation device: $DEVICE"
info "Pool name: $POOL_NAME"
info "Root mount point: $ROOT_MOUNT"
echo ""

warn "WARNING: This will DESTROY all data on $DEVICE"
read -p "Type 'YES' to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    info "Installation cancelled"
    exit 0
fi

# Step 2: Partition the disk
info "Step 1/5: Partitioning disk..."
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
"$SCRIPT_DIR/zfs-partition.sh" "$DEVICE" "$EFI_SIZE"

# Determine partition names
if [[ "$DEVICE" == *"nvme"* ]] || [[ "$DEVICE" == *"mmcblk"* ]]; then
    EFI_PART="${DEVICE}p1"
    ZFS_PART="${DEVICE}p2"
else
    EFI_PART="${DEVICE}1"
    ZFS_PART="${DEVICE}2"
fi

info "EFI Partition: $EFI_PART"
info "ZFS Partition: $ZFS_PART"
echo ""

# Step 3: Create ZFS pool and datasets
info "Step 2/5: Creating ZFS pool and datasets..."
"$SCRIPT_DIR/zfs-pool-create.sh" "$ZFS_PART" "$POOL_NAME"
echo ""

# Step 4: Mount filesystems
info "Step 3/5: Mounting filesystems..."
mkdir -p "$ROOT_MOUNT"

# Mount root dataset
info "Mounting root dataset..."
zfs mount "$POOL_NAME/ROOT/pop"

# Mount other datasets
zfs mount -a

# Mount EFI partition
mkdir -p "$ROOT_MOUNT/boot/efi"
mount "$EFI_PART" "$ROOT_MOUNT/boot/efi"

info "Filesystems mounted:"
mount | grep "$ROOT_MOUNT"
echo ""

# Step 5: Install system (placeholder - this would call debootstrap or distinst)
info "Step 4/5: System installation..."
warn "This script prepares the ZFS environment."
warn "You should now run your installer (distinst/pop-installer) targeting $ROOT_MOUNT"
warn "Or manually run debootstrap and configure the system."
echo ""
info "After system installation, run the following to complete ZFS setup:"
info "  $SCRIPT_DIR/zbm-install.sh $ROOT_MOUNT $EFI_PART"
echo ""

# Step 6: Information for manual completion
info "Step 5/5: Next steps..."
cat << EOF

ZFS environment is ready for installation.

Manual installation steps:
1. Install base system to $ROOT_MOUNT
2. Install ZFS packages in chroot:
   chroot $ROOT_MOUNT apt-get install -y zfsutils-linux zfs-initramfs zfs-dkms
3. Install ZFSBootMenu:
   $SCRIPT_DIR/zbm-install.sh $ROOT_MOUNT $EFI_PART
4. Configure system (hostname, users, etc.)
5. Unmount and reboot

Or use the automated installer targeting $ROOT_MOUNT

ZFS Pool: $POOL_NAME
Root Dataset: $POOL_NAME/ROOT/pop
EFI Partition: $EFI_PART (mounted at $ROOT_MOUNT/boot/efi)

EOF

info "ZFS preparation complete!"
