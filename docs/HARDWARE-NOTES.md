# System76 Hardware-Specific Notes

This document covers specific notes, tips, and configurations for System76 hardware with Pop!_OS ZFS.

## Tested Hardware

### Meerkat 10

**Specifications:**
- Form Factor: Mini PC
- CPU: Intel Core (various configurations)
- RAM: Up to 64GB DDR4/DDR5
- Storage: M.2 NVMe SSD
- Graphics: Intel Iris Xe / Intel UHD

**ZFS Compatibility:** ✅ Fully Supported

**Installation Notes:**
- Device path typically: `/dev/nvme0n1`
- 512MB EFI partition recommended
- Works great with ZFS encryption
- Excellent for ZFSBootMenu (fast boot times)

**Recommended Settings:**
```bash
# During installation
export DEVICE=/dev/nvme0n1
export POOL_NAME=rpool
export EFI_SIZE=512

# ZFS pool creation
# Default settings work well, ashift=12 is optimal for NVMe
```

**Performance:**
- NVMe SSDs benefit greatly from ZFS with compression
- Recommend enabling autotrim for NVMe longevity
- Typical compression ratio: 1.5x - 2x (depends on data)

**Known Issues:**
- None specific to ZFS

### Serval WS

**Specifications:**
- Form Factor: Mobile Workstation Laptop (15.6" or 17.3")
- CPU: Intel Core i7/i9 or AMD Ryzen
- RAM: Up to 64GB DDR4/DDR5
- Storage: Dual M.2 NVMe slots
- Graphics: NVIDIA RTX (discrete) + Intel/AMD (integrated)

**ZFS Compatibility:** ✅ Fully Supported

**Installation Notes:**
- Device paths: `/dev/nvme0n1`, `/dev/nvme1n1` (if dual drives)
- NVIDIA drivers should be installed for graphics acceleration
- Discrete GPU works with ZFS root filesystem

**Dual Drive Configuration:**

If your Serval has two NVMe drives, consider:

**Option 1: Mirrored Pool (Redundancy)**
```bash
# Create mirrored ZFS pool for redundancy
zpool create -f \
    -o ashift=12 \
    -O compression=lz4 \
    -O encryption=aes-256-gcm \
    -O keylocation=prompt \
    -O keyformat=passphrase \
    rpool mirror /dev/nvme0n1p2 /dev/nvme1n1p2
```

**Option 2: Separate Pools**
```bash
# System on nvme0n1
zpool create rpool /dev/nvme0n1p2

# Data/work on nvme1n1
zpool create data /dev/nvme1n1p1
```

**NVIDIA Configuration:**

The ZFS ISO includes NVIDIA drivers when built with `NVIDIA=1`.

Ensure NVIDIA drivers are working:
```bash
nvidia-smi
```

If issues occur, reinstall:
```bash
sudo apt install --reinstall nvidia-driver-580-open
sudo update-initramfs -u -k all
sudo generate-zbm
```

**Known Issues:**
- Early KMS with NVIDIA requires special kernel parameters
- Add to ZFSBootMenu: `nvidia-drm.modeset=1`

**Power Management:**

For laptops, configure power management:
```bash
# Install system76-power
sudo apt install system76-power

# Enable power profiles
sudo systemctl enable system76-power
```

## General System76 Hardware

### system76-driver

Install System76 driver for hardware support:
```bash
sudo apt install system76-driver
```

This provides:
- Hardware-specific configurations
- Function key support
- Fan control
- Firmware updates

### Firmware Updates

System76 firmware manager works with ZFS:
```bash
sudo apt install system76-firmware-daemon firmware-manager

# Check for updates
firmware-manager
```

### system76-power

Graphics switching and power profiles:
```bash
sudo apt install system76-power

# View current graphics mode (for hybrid graphics)
system76-power graphics

# Switch to NVIDIA
sudo system76-power graphics nvidia

# Switch to integrated
sudo system76-power graphics integrated

# Switch to hybrid
sudo system76-power graphics hybrid
```

After switching, reboot for changes to take effect.

## ZFS-Specific Configurations

### RAM Recommendations

ZFS benefits from more RAM for ARC (Adaptive Replacement Cache):

**Minimum RAM:**
- 8GB for basic use
- 16GB recommended for desktop
- 32GB+ ideal for workstation use

**ARC Size:**
ZFS will use up to 50% of system RAM for cache by default. This is normal and beneficial.

View ARC statistics:
```bash
arc_summary
```

Limit ARC size if needed (e.g., for VMs):
```bash
# Limit to 8GB
echo 8589934592 | sudo tee /sys/module/zfs/parameters/zfs_arc_max

# Make permanent
echo "options zfs zfs_arc_max=8589934592" | sudo tee /etc/modprobe.d/zfs.conf
sudo update-initramfs -u -k all
```

### NVMe Optimization

System76 systems use NVMe drives. Optimal settings:

```bash
# During pool creation (already set in scripts)
# -o ashift=12        # 4K sectors
# -o autotrim=on      # TRIM support
```

Check TRIM is enabled:
```bash
zpool get autotrim rpool
```

Manual TRIM (if autotrim is off):
```bash
sudo zpool trim rpool
```

### Hibernation with ZFS

Hibernation works with ZFS but requires setup:

1. Create swap zvol:
```bash
# Create 16GB swap (adjust to your RAM size)
zfs create -V 16G -b $(getconf PAGESIZE) \
    -o compression=zle \
    -o logbias=throughput \
    -o sync=always \
    -o primarycache=metadata \
    -o secondarycache=none \
    -o com.sun:auto-snapshot=false \
    rpool/swap

# Format as swap
mkswap -f /dev/zvol/rpool/swap

# Enable swap
swapon /dev/zvol/rpool/swap
```

2. Add to `/etc/fstab`:
```
/dev/zvol/rpool/swap none swap defaults 0 0
```

3. Configure hibernate:
```bash
# Get swap device
ls -l /dev/zvol/rpool/swap

# Add to kernel parameters in ZFSBootMenu
zfs set org.zfsbootmenu:commandline="quiet splash resume=/dev/zvol/rpool/swap" rpool/ROOT/pop
```

4. Regenerate ZFSBootMenu:
```bash
sudo generate-zbm
```

## Troubleshooting

### Boot Issues on System76 Hardware

If system doesn't boot after ZFS installation:

1. **Check Secure Boot:**
   - Enter UEFI/BIOS (usually ESC or F2 at boot)
   - Disable Secure Boot
   - Save and exit

2. **Check Boot Order:**
   - Ensure ZFSBootMenu EFI entry is first
   - Or manually select it from boot menu (F7)

3. **Manually Add Boot Entry:**
```bash
# Boot from live ISO
sudo efibootmgr -c -d /dev/nvme0n1 -p 1 \
    -L "ZFSBootMenu" \
    -l '\EFI\zbm\vmlinuz.efi'
```

### NVIDIA Issues

If NVIDIA graphics don't work after installation:

```bash
# Check driver is installed
dpkg -l | grep nvidia-driver

# Reinstall if needed
sudo apt install --reinstall nvidia-driver-580-open

# Regenerate initramfs and ZFSBootMenu
sudo update-initramfs -u -k all
sudo generate-zbm

# Reboot
sudo reboot
```

### Function Keys Not Working

Install system76-driver:
```bash
sudo apt install system76-driver system76-dkms
```

### Touchpad Issues

Usually resolved with:
```bash
sudo apt install xserver-xorg-input-libinput
```

## Performance Tuning

### Desktop Use

Default settings are optimal for desktop use.

### Workstation/Development Use

For heavy I/O workloads:

```bash
# Increase ARC size (if you have RAM to spare)
# Set to 75% of RAM on workstation
# Example: 24GB out of 32GB
echo "options zfs zfs_arc_max=25769803776" | sudo tee /etc/modprobe.d/zfs.conf

# Increase dirty data threshold for better write performance
echo "options zfs zfs_dirty_data_max=4294967296" | sudo tee -a /etc/modprobe.d/zfs.conf

# Update initramfs
sudo update-initramfs -u -k all

# Reboot for changes to take effect
sudo reboot
```

### Development with ZFS

Create separate dataset for development:
```bash
sudo zfs create -o compression=lz4 -o recordsize=128k rpool/USERDATA/dev
sudo chown $USER:$USER /home/$USER/dev
```

Benefits:
- Separate snapshot policies
- Can tune for specific workload
- Easy to backup/replicate

## Backup Recommendations

### Internal to External

For System76 systems, use an external USB drive:

```bash
# Connect USB drive and create ZFS pool
sudo zpool create backup /dev/sdb

# Initial replication
sudo syncoid -r rpool/USERDATA backup/userdata-backup

# Subsequent runs (incremental)
sudo syncoid -r rpool/USERDATA backup/userdata-backup

# Detach safely
sudo zpool export backup
```

### Network Backup

Use another System76 machine or NAS as backup target:

```bash
# Weekly backup to remote system
syncoid -r rpool/USERDATA user@backup-server:backup/laptop-userdata
```

## Resources

- [System76 Support](https://support.system76.com/)
- [System76 GitHub](https://github.com/system76)
- [Pop!_OS Docs](https://support.system76.com/articles/pop-basics/)

## See Also

- [Installation Guide](ZFS-INSTALL.md)
- [Building ISO](BUILDING.md)
- [Recovery Guide](ZFS-RECOVERY.md)
- [Snapshot Management](SNAPSHOT-MANAGEMENT.md)
