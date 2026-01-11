# ZFS Integration Testing Checklist

This document provides a comprehensive checklist for testing the Pop!_OS ZFS integration.

## Pre-Build Testing

### Repository Validation
- [x] All required files present (run `./validate-zfs-integration.sh`)
- [x] Scripts have executable permissions
- [x] Configuration files are syntactically correct
- [ ] Makefile includes work correctly
- [ ] No broken symbolic links

### Documentation Review
- [x] Installation guide is complete
- [x] Recovery guide covers all scenarios
- [x] Build guide has clear instructions
- [x] Hardware notes are accurate
- [x] Snapshot management guide is comprehensive

## Build Testing

### ISO Build
- [ ] Clean build succeeds: `make distclean && make DISTRO_VERSION=24.04 iso`
- [ ] ZFS packages are included in ISO
- [ ] ZFSBootMenu packages are present
- [ ] Sanoid and snapshot tools are included
- [ ] Build completes without errors
- [ ] ISO file is created at expected location

### Build Variants
- [ ] Standard build (no NVIDIA)
- [ ] NVIDIA variant: `make NVIDIA=1 iso`
- [ ] HP variant: `make HP=1 iso`
- [ ] Combined: `make NVIDIA=1 HP=1 iso`

### Reproducibility
- [ ] First build completes successfully
- [ ] SHA256 checksum recorded
- [ ] Clean rebuild: `make distclean && make iso`
- [ ] Second build SHA256 matches first (reproducible)
- [ ] Container build produces same result

### Container Build
- [ ] Containerfile builds successfully
- [ ] Container-based ISO build works
- [ ] Output ISO matches native build

## Live Environment Testing

### Boot Testing
- [ ] ISO boots in QEMU UEFI mode
- [ ] ISO boots in QEMU BIOS mode (amd64)
- [ ] ISO boots on real hardware
- [ ] COSMIC desktop loads correctly
- [ ] Network connectivity works

### ZFS Availability
- [ ] `zpool` command is available
- [ ] `zfs` command is available
- [ ] ZFS kernel module loads: `lsmod | grep zfs`
- [ ] Can create test pool: `zpool create test /tmp/test.img`
- [ ] Can import existing pools: `zpool import`

### Installation Tools
- [ ] Installation scripts are present in `/usr/local/bin/`
- [ ] Scripts have correct permissions
- [ ] Scripts can be executed
- [ ] Help text displays correctly

## Installation Testing

### Disk Partitioning
- [ ] `zfs-partition.sh` creates GPT table
- [ ] EFI partition created (512MB, FAT32)
- [ ] ZFS partition uses remainder of disk
- [ ] Partition table is correct: `gdisk -l /dev/sdX`

### Pool Creation
- [ ] `zfs-pool-create.sh` creates encrypted pool
- [ ] Encryption prompts for passphrase
- [ ] Pool has correct properties (ashift=12, compression=lz4)
- [ ] All datasets are created correctly
- [ ] Dataset layout matches specification
- [ ] Bootfs property is set: `zpool get bootfs rpool`

### System Installation
- [ ] Base system installs to ZFS root
- [ ] ZFS packages install in target
- [ ] Kernel installs successfully
- [ ] Initramfs includes ZFS modules

### ZFSBootMenu Installation
- [ ] `zbm-install.sh` runs without errors
- [ ] ZFSBootMenu packages install
- [ ] EFI bundle generates successfully
- [ ] EFI files present in `/boot/efi/EFI/zbm/`
- [ ] EFI boot entry created: `efibootmgr -v`
- [ ] Kernel hooks installed

## First Boot Testing

### Boot Process
- [ ] System boots to ZFSBootMenu
- [ ] ZFSBootMenu displays boot environments
- [ ] Can navigate menu with arrow keys
- [ ] Selected BE is highlighted
- [ ] Enter key boots selected environment

### Encryption
- [ ] System prompts for ZFS passphrase
- [ ] Correct passphrase unlocks pool
- [ ] Incorrect passphrase rejected
- [ ] Pool imports successfully after unlock
- [ ] Datasets mount correctly

### System Boot
- [ ] Kernel loads successfully
- [ ] Initramfs runs correctly
- [ ] Root filesystem mounts
- [ ] System boots to login
- [ ] COSMIC desktop loads
- [ ] Network is available

### Post-Boot Verification
- [ ] Pool is imported: `zpool status`
- [ ] All datasets mounted: `zfs mount`
- [ ] Root is on ZFS: `df -h /`
- [ ] Encryption is active: `zfs get encryption rpool`
- [ ] ZFS services running: `systemctl status zfs-*`

## Snapshot Testing

### Sanoid Configuration
- [ ] Sanoid is installed
- [ ] Configuration file present: `/etc/sanoid/sanoid.conf`
- [ ] Configuration is valid: `sanoid --configdir=/etc/sanoid --dry-run`
- [ ] Timer is enabled: `systemctl status sanoid.timer`
- [ ] Timer schedule is correct: `systemctl list-timers sanoid.timer`

### Manual Snapshots
- [ ] Can create snapshot: `zfs snapshot rpool/ROOT/pop@test`
- [ ] Snapshot appears in list: `zfs list -t snapshot`
- [ ] Can access snapshot: `ls /.zfs/snapshot/`
- [ ] Can restore from snapshot
- [ ] Can delete snapshot: `zfs destroy rpool/ROOT/pop@test`

### Automatic Snapshots
- [ ] APT hook is present: `/etc/apt/apt.conf.d/80-zfs-snapshot`
- [ ] Helper script exists: `/usr/local/bin/apt-zfs-snapshot`
- [ ] Snapshot created before `apt upgrade`
- [ ] Snapshot has correct naming: `@apt_YYYY-MM-DD_HH:MM:SS`
- [ ] Old snapshots are cleaned up

### Pre-Boot Snapshots
- [ ] Service is enabled: `systemctl status zfs-pre-boot-snapshot.service`
- [ ] Script exists: `/usr/local/bin/zfs-pre-boot-snapshot`
- [ ] Snapshot created on reboot
- [ ] Only last 5 pre-boot snapshots kept
- [ ] Naming is correct: `@pre-boot_YYYY-MM-DD_HH:MM:SS`

### Sanoid Automation
- [ ] Wait for sanoid timer to run (or run manually: `sanoid`)
- [ ] Hourly snapshots created
- [ ] Snapshots follow template policies
- [ ] Old snapshots pruned according to policy
- [ ] No errors in logs: `journalctl -u sanoid.service`

## Recovery Testing

### ZFSBootMenu Recovery
- [ ] Press 'S' in ZFSBootMenu to view snapshots
- [ ] Snapshots are listed correctly
- [ ] Can boot from snapshot
- [ ] System boots read-only from snapshot
- [ ] Can verify snapshot contents

### Snapshot Rollback
- [ ] Make test change to system
- [ ] Create snapshot after change
- [ ] Rollback to pre-change snapshot
- [ ] Change is reverted after rollback
- [ ] System boots correctly after rollback

### Boot Environment Cloning
- [ ] Clone BE: `zfs clone rpool/ROOT/pop@snap rpool/ROOT/pop-clone`
- [ ] Set properties on clone
- [ ] New BE appears in ZFSBootMenu
- [ ] Can boot from cloned BE
- [ ] Can switch default BE: `zpool set bootfs=...`

### Live ISO Recovery
- [ ] Boot from live ISO
- [ ] Can import pool: `zpool import -f rpool`
- [ ] Can unlock encrypted pool
- [ ] Can mount datasets
- [ ] Can chroot into installed system
- [ ] Can fix issues and reboot

### Recovery Shell
- [ ] Press 'R' in ZFSBootMenu for recovery shell
- [ ] Shell loads successfully
- [ ] ZFS commands available
- [ ] Can diagnose issues
- [ ] Can repair system
- [ ] Can reboot from shell

## Performance Testing

### Compression
- [ ] Compression is enabled: `zfs get compression`
- [ ] Compression ratio reasonable: `zfs get compressratio`
- [ ] File writes are fast
- [ ] File reads are fast

### Caching
- [ ] ARC is caching data: `arc_summary`
- [ ] Cache hit ratio is good (>80%)
- [ ] Memory usage is appropriate

### TRIM Support
- [ ] Autotrim enabled: `zpool get autotrim`
- [ ] Can manually trim: `zpool trim rpool`
- [ ] Trim completes successfully

## Hardware-Specific Testing

### Meerkat 10
- [ ] Installation completes successfully
- [ ] NVMe device recognized (/dev/nvme0n1)
- [ ] Boot time is acceptable
- [ ] System is stable
- [ ] All hardware works (WiFi, Bluetooth, USB)

### Serval WS
- [ ] Installation completes successfully
- [ ] NVIDIA drivers work (if NVIDIA build)
- [ ] Dual drive configuration supported
- [ ] Graphics switching works
- [ ] All hardware works (touchpad, function keys)

## NVIDIA Testing (NVIDIA variant only)

### Driver Installation
- [ ] NVIDIA driver installs correctly
- [ ] Driver version is correct: `nvidia-smi`
- [ ] GPU detected and working

### Graphics
- [ ] X11/Wayland session starts
- [ ] GPU acceleration works
- [ ] OpenGL applications work: `glxinfo`
- [ ] CUDA works (if testing compute)

### Boot Parameters
- [ ] NVIDIA kernel parameters set correctly
- [ ] Early KMS works
- [ ] No graphical glitches

## Documentation Testing

### Installation Guide
- [ ] Steps are clear and complete
- [ ] Commands execute successfully
- [ ] Screenshots/examples are accurate
- [ ] Troubleshooting section helps

### Recovery Guide
- [ ] Recovery procedures work
- [ ] Snapshot restoration works
- [ ] Emergency recovery works
- [ ] Examples are correct

### Build Guide
- [ ] Build instructions work
- [ ] Options are documented
- [ ] Troubleshooting is helpful

## CI/CD Testing

### GitHub Actions
- [ ] Workflow file is valid
- [ ] Build job runs successfully
- [ ] Artifacts are uploaded
- [ ] Multiple variants build correctly
- [ ] Build fails on errors (doesn't silently fail)

## Regression Testing

### After Changes
- [ ] Build still works
- [ ] Installation still works
- [ ] Boot still works
- [ ] Snapshots still work
- [ ] Recovery still works

## Sign-Off

### Required Tests
The following tests MUST pass before release:
- [ ] ISO builds successfully
- [ ] ISO boots in live environment
- [ ] Installation completes
- [ ] System boots from ZFS
- [ ] Snapshots work
- [ ] Recovery from snapshot works

### Optional Tests
The following tests are recommended but not blocking:
- [ ] Reproducible builds
- [ ] Container builds
- [ ] Hardware-specific tests
- [ ] Performance benchmarks

## Notes

Record any issues, workarounds, or observations here:

```
Date: YYYY-MM-DD
Tester: [Name]
Version: [ISO Version]
Hardware: [System Description]

Issues:
- [Issue 1]
- [Issue 2]

Workarounds:
- [Workaround 1]

Notes:
- [Additional notes]
```
