# Pop!_OS ZFS Installation Guide

This guide covers installing Pop!_OS 24.04 with ZFS root filesystem and ZFSBootMenu.

## Prerequisites

- Pop!_OS 24.04 ZFS ISO (built using this repository)
- Target system with UEFI firmware
- At least 16GB RAM recommended (for live environment + installation)
- Target disk with at least 32GB space

## Installation Methods

### Method 1: Automated Script Installation (Recommended)

Boot the ZFS-enabled Pop!_OS ISO and use the automated installation scripts.

#### Step 1: Boot Live Environment

Boot from the Pop!_OS ZFS ISO. The ZFS kernel module should load automatically.

#### Step 2: Verify ZFS is Available

```bash
sudo -i
zpool version
zfs version
```

#### Step 3: Run Automated Installation

```bash
# Set your target device (e.g., /dev/sda, /dev/nvme0n1)
export DEVICE=/dev/sda
export POOL_NAME=rpool
export ROOT_MOUNT=/mnt

# Run the main installation script
/usr/local/bin/zfs-install.sh
```

The script will:
1. Partition the disk (512MB EFI + remainder for ZFS)
2. Create encrypted ZFS pool with optimal settings
3. Create dataset layout (ROOT/pop, USERDATA/home, var/*, etc.)
4. Mount filesystems at /mnt

#### Step 4: Install Base System

Use one of these methods to install the base system:

**Option A: Using Pop Installer** (if available in live environment)
```bash
# Launch the Pop installer and configure it to install to /mnt
pop-installer --root-path /mnt
```

**Option B: Manual debootstrap**
```bash
# Install base system
debootstrap noble /mnt http://apt.pop-os.org/ubuntu

# Mount system directories
mount --bind /dev /mnt/dev
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -t tmpfs run /mnt/run

# Enter chroot
chroot /mnt /bin/bash

# Set hostname
echo "pop-zfs" > /etc/hostname

# Configure networking
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback
EOF

# Install essential packages
apt update
apt install -y zfsutils-linux zfs-initramfs zfs-dkms \
    linux-image-generic linux-headers-generic \
    systemd systemd-boot cosmic-desktop \
    network-manager sudo
```

#### Step 5: Install ZFSBootMenu

```bash
# From live environment (not chroot)
/usr/local/bin/zbm-install.sh /mnt /dev/sda1
```

This will:
- Install ZFSBootMenu packages
- Generate ZFSBootMenu EFI bundle
- Configure EFI boot entry
- Set up kernel hooks for automatic regeneration

#### Step 6: Configure System

```bash
# Chroot into installed system
chroot /mnt /bin/bash

# Set root password
passwd

# Create user account
useradd -m -G sudo,adm -s /bin/bash username
passwd username

# Set timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# Configure locale
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# Enable ZFS services
systemctl enable zfs-import-cache.service
systemctl enable zfs-mount.service
systemctl enable zfs-zed.service
systemctl enable zfs.target

# Exit chroot
exit
```

#### Step 7: Install Snapshot Automation

```bash
chroot /mnt /bin/bash

# Install sanoid for automated snapshots
apt install -y sanoid

# Copy sanoid configuration
cp /usr/share/doc/pop-os-zfs/sanoid.conf.template /etc/sanoid/sanoid.conf

# Edit configuration to match your pool name
sed -i 's/rpool/YOUR_POOL_NAME/g' /etc/sanoid/sanoid.conf

# Enable sanoid timer
systemctl enable sanoid.timer

# Install APT snapshot hooks
cp /usr/share/doc/pop-os-zfs/apt-zfs-snapshot.sh /usr/local/bin/apt-zfs-snapshot
chmod +x /usr/local/bin/apt-zfs-snapshot
cp /usr/share/doc/pop-os-zfs/80-zfs-snapshot /etc/apt/apt.conf.d/

# Install pre-boot snapshot service
cp /usr/share/doc/pop-os-zfs/zfs-pre-boot-snapshot.sh /usr/local/bin/zfs-pre-boot-snapshot
chmod +x /usr/local/bin/zfs-pre-boot-snapshot
cp /usr/share/doc/pop-os-zfs/zfs-pre-boot-snapshot.service /etc/systemd/system/
systemctl enable zfs-pre-boot-snapshot.service

exit
```

#### Step 8: Unmount and Reboot

```bash
# Unmount everything
umount /mnt/boot/efi
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt/run

# Export ZFS pool
zfs umount -a
zpool export rpool

# Reboot
reboot
```

### Method 2: Manual Installation

For advanced users who want full control, follow the manual steps in the scripts but execute each command individually with your preferred options.

## Post-Installation

### First Boot

1. System will boot into ZFSBootMenu
2. Select your boot environment (should show "rpool/ROOT/pop")
3. Press Enter to boot
4. Enter ZFS encryption passphrase (if encryption was enabled)
5. System will boot into Pop!_OS

### Verify Installation

```bash
# Check ZFS pool status
zpool status

# List datasets
zfs list

# Verify bootfs property
zpool get bootfs rpool

# Check snapshots
zfs list -t snapshot

# Verify sanoid timer
systemctl status sanoid.timer
```

## Troubleshooting

### ZFSBootMenu doesn't appear
- Verify EFI boot entry: `efibootmgr -v`
- Check if ZFSBootMenu EFI file exists: `ls /boot/efi/EFI/zbm/`
- Manually select boot entry in UEFI firmware settings

### Cannot import pool
- Check if pool is exported: `zpool import`
- Import manually: `zpool import -f rpool`
- Verify encryption key: `zfs load-key rpool`

### System won't boot
- Boot from live ISO
- Import pool: `zpool import -f -R /mnt rpool`
- Load encryption key: `zfs load-key rpool`
- Mount datasets: `zfs mount rpool/ROOT/pop && zfs mount -a`
- Chroot and investigate: `chroot /mnt /bin/bash`

### Snapshot restore
See [ZFS-RECOVERY.md](ZFS-RECOVERY.md) for detailed recovery procedures.

## Next Steps

- Configure automatic snapshots: [SNAPSHOT-MANAGEMENT.md](SNAPSHOT-MANAGEMENT.md)
- Learn recovery procedures: [ZFS-RECOVERY.md](ZFS-RECOVERY.md)
- System76 hardware notes: [HARDWARE-NOTES.md](HARDWARE-NOTES.md)
