# Pop!_OS ZFS Recovery Guide

This guide covers recovery procedures using ZFSBootMenu and ZFS snapshots.

## Table of Contents

1. [Accessing Recovery Mode](#accessing-recovery-mode)
2. [Snapshot Rollback](#snapshot-rollback)
3. [Boot Environment Management](#boot-environment-management)
4. [Emergency Recovery](#emergency-recovery)

## Accessing Recovery Mode

### From ZFSBootMenu

When the system boots, you'll see the ZFSBootMenu interface:

```
ZFSBootMenu v2.x
────────────────────────────────────────
→ rpool/ROOT/pop
  rpool/ROOT/pop-backup
  
[K] Kernels  [S] Snapshots  [D] Set default
[E] Edit cmdline  [R] Recovery shell  [P] Pool status
```

#### Navigation
- **Arrow keys**: Navigate between boot environments
- **Enter**: Boot selected environment
- **K**: View available kernels for selected environment
- **S**: View and manage snapshots
- **R**: Drop to recovery shell
- **P**: View pool status and health

## Snapshot Rollback

### View Available Snapshots

1. In ZFSBootMenu, select your boot environment
2. Press **S** to view snapshots
3. You'll see a list of snapshots:

```
Snapshots for rpool/ROOT/pop
────────────────────────────────────────
→ @apt_2024-01-10_14:30:00
  @pre-boot_2024-01-10_08:15:00
  @autosnap_2024-01-10_12:00:00_hourly
  @autosnap_2024-01-09_00:00:00_daily
```

### Boot from Snapshot

1. Select a snapshot with arrow keys
2. Press **Enter** to boot from that snapshot
3. System will boot using the snapshot as read-only root
4. This is useful for verifying a snapshot before rollback

### Rollback to Snapshot

To permanently rollback to a snapshot:

1. Boot from live ISO or recovery shell
2. Import the pool:
   ```bash
   zpool import -f rpool
   zfs load-key rpool  # If encrypted
   ```

3. Rollback the dataset:
   ```bash
   zfs rollback rpool/ROOT/pop@snapshot-name
   ```

   **WARNING**: This destroys all snapshots and changes newer than the target snapshot!

4. For safer rollback, clone the snapshot instead:
   ```bash
   zfs clone rpool/ROOT/pop@snapshot-name rpool/ROOT/pop-recovered
   zpool set bootfs=rpool/ROOT/pop-recovered rpool
   ```

5. Reboot:
   ```bash
   zpool export rpool
   reboot
   ```

### Selective File Recovery

To recover specific files from a snapshot without full rollback:

1. Snapshots are accessible in `.zfs/snapshot/` directory:
   ```bash
   cd /
   ls .zfs/snapshot/
   ```

2. Copy files from snapshot:
   ```bash
   cp .zfs/snapshot/apt_2024-01-10_14:30:00/etc/some-config.conf /etc/
   ```

3. Or browse snapshots:
   ```bash
   cd .zfs/snapshot/apt_2024-01-10_14:30:00
   ls -la
   ```

## Boot Environment Management

### List Boot Environments

```bash
zfs list -r rpool/ROOT
```

### Create New Boot Environment

Before major changes, create a new boot environment:

```bash
# Clone current environment
zfs snapshot rpool/ROOT/pop@backup
zfs clone rpool/ROOT/pop@backup rpool/ROOT/pop-backup

# Set properties for new BE
zfs set canmount=noauto rpool/ROOT/pop-backup
zfs set mountpoint=/ rpool/ROOT/pop-backup
zfs set org.zfsbootmenu:commandline="quiet splash" rpool/ROOT/pop-backup
zfs set org.zfsbootmenu:active=on rpool/ROOT/pop-backup
```

### Switch Boot Environments

```bash
# Set new default boot environment
zpool set bootfs=rpool/ROOT/pop-backup rpool

# Reboot
reboot
```

In ZFSBootMenu, the new BE will be marked as default (→).

### Delete Boot Environment

```bash
# Destroy old boot environment (be careful!)
zfs destroy -r rpool/ROOT/pop-old
```

### Rename Boot Environment

```bash
zfs rename rpool/ROOT/pop rpool/ROOT/pop-old
zfs rename rpool/ROOT/pop-new rpool/ROOT/pop
zpool set bootfs=rpool/ROOT/pop rpool
```

## Emergency Recovery

### System Won't Boot

#### Option 1: Boot from ZFSBootMenu Snapshot

1. In ZFSBootMenu, press **S** to view snapshots
2. Select a working snapshot
3. Press **Enter** to boot
4. Once booted, investigate and fix the issue
5. Rollback if needed

#### Option 2: Recovery Shell

1. In ZFSBootMenu, press **R** for recovery shell
2. Import pool:
   ```bash
   zpool import -f rpool
   zfs load-key rpool  # If encrypted
   ```

3. Mount root filesystem:
   ```bash
   zfs mount rpool/ROOT/pop
   zfs mount -a
   ```

4. Chroot into system:
   ```bash
   mount --bind /dev /mnt/dev
   mount -t proc proc /mnt/proc
   mount -t sysfs sys /mnt/sys
   chroot /mnt /bin/bash
   ```

5. Fix issues (reinstall kernel, fix config, etc.)
6. Exit and reboot:
   ```bash
   exit
   umount -R /mnt
   zfs umount -a
   zpool export rpool
   reboot
   ```

#### Option 3: Live ISO Recovery

1. Boot from Pop!_OS ZFS live ISO
2. Open terminal and become root:
   ```bash
   sudo -i
   ```

3. Import pool:
   ```bash
   zpool import -f rpool
   zfs load-key rpool  # If encrypted
   ```

4. List available datasets:
   ```bash
   zfs list
   ```

5. Mount root:
   ```bash
   zfs set mountpoint=/mnt rpool/ROOT/pop
   zfs mount rpool/ROOT/pop
   zfs mount -a
   ```

6. Mount EFI partition:
   ```bash
   mount /dev/sda1 /mnt/boot/efi  # Adjust device as needed
   ```

7. Bind mount system directories:
   ```bash
   mount --bind /dev /mnt/dev
   mount -t proc proc /mnt/proc
   mount -t sysfs sys /mnt/sys
   mount -t tmpfs run /mnt/run
   ```

8. Chroot:
   ```bash
   chroot /mnt /bin/bash
   ```

9. Perform recovery:
   - Reinstall packages: `apt install --reinstall package-name`
   - Rebuild initramfs: `update-initramfs -u -k all`
   - Regenerate ZFSBootMenu: `generate-zbm`
   - Fix configuration files
   - Check logs: `journalctl -xe`

10. Exit and cleanup:
    ```bash
    exit
    umount /mnt/boot/efi
    umount /mnt/dev /mnt/proc /mnt/sys /mnt/run
    zfs umount -a
    zpool export rpool
    reboot
    ```

### Corrupted Pool

#### Check Pool Health

```bash
zpool status rpool
```

#### Scrub Pool

```bash
zpool scrub rpool
```

Wait for scrub to complete (check with `zpool status`).

#### Clear Errors

```bash
zpool clear rpool
```

### Lost Encryption Key

If you lose the encryption passphrase:
- **Data is unrecoverable** (encryption is working as designed)
- Backup your encrypted data regularly to external storage
- Consider storing passphrase in secure password manager

### ZFSBootMenu Not Found

1. Boot from live ISO
2. Import pool and mount:
   ```bash
   zpool import -f rpool
   zfs load-key rpool
   zfs mount rpool/ROOT/pop
   mount /dev/sda1 /mnt/boot/efi
   ```

3. Reinstall ZFSBootMenu:
   ```bash
   mount --bind /dev /mnt/dev
   mount -t proc proc /mnt/proc
   mount -t sysfs sys /mnt/sys
   chroot /mnt /bin/bash
   
   apt install --reinstall zfsbootmenu
   generate-zbm
   
   efibootmgr --create --disk /dev/sda --part 1 \
     --label "ZFSBootMenu" \
     --loader '\EFI\zbm\vmlinuz.efi'
   ```

### Kernel Panic or Boot Issues

1. Boot from older snapshot or BE in ZFSBootMenu
2. Once booted, check logs:
   ```bash
   journalctl -b -p err
   dmesg | grep -i error
   ```

3. Reinstall kernel:
   ```bash
   apt install --reinstall linux-image-generic
   update-initramfs -u -k all
   generate-zbm
   ```

## Best Practices

1. **Regular Snapshots**: Enable sanoid for automated snapshots
2. **Test Backups**: Periodically boot from snapshots to verify they work
3. **Multiple Boot Environments**: Keep a backup BE before major updates
4. **Document Changes**: Note what you changed before taking snapshots
5. **External Backups**: ZFS snapshots are not backups! Use syncoid for remote replication

## See Also

- [Snapshot Management Guide](SNAPSHOT-MANAGEMENT.md)
- [Installation Guide](ZFS-INSTALL.md)
- [Building ISO](BUILDING.md)
