# ZFS Snapshot Management with Sanoid

This guide covers automated snapshot management using sanoid and syncoid.

## Table of Contents

1. [Introduction](#introduction)
2. [Sanoid Configuration](#sanoid-configuration)
3. [Manual Snapshot Management](#manual-snapshot-management)
4. [Syncoid - Remote Replication](#syncoid---remote-replication)
5. [Best Practices](#best-practices)

## Introduction

### What is Sanoid?

Sanoid is a policy-driven snapshot management tool that:
- Automatically creates snapshots on a schedule
- Automatically prunes old snapshots based on retention policies
- Provides flexible policies for different datasets
- Integrates with systemd timers

### What is Syncoid?

Syncoid is a companion tool to sanoid that:
- Efficiently replicates ZFS snapshots to remote systems
- Uses ZFS send/receive with intelligent delta detection
- Compresses transfers to save bandwidth
- Can be used for off-site backups

## Sanoid Configuration

### Default Configuration

Pop!_OS ZFS installations come with a pre-configured sanoid setup at `/etc/sanoid/sanoid.conf`:

```ini
# Production template for root filesystems
[rpool/ROOT]
    use_template = production
    recursive = yes

# User data with longer retention
[rpool/USERDATA]
    use_template = userdata
    recursive = yes

# Logs with shorter retention
[rpool/var/log]
    use_template = logs
    recursive = yes
```

### Snapshot Templates

#### Production Template (System Files)
- Hourly: 24 snapshots (1 day)
- Daily: 30 snapshots (1 month)
- Monthly: 6 snapshots (6 months)
- Yearly: 1 snapshot

#### Userdata Template (User Files)
- Hourly: 48 snapshots (2 days)
- Daily: 90 snapshots (3 months)
- Monthly: 12 snapshots (1 year)
- Yearly: 2 snapshots

#### Logs Template (System Logs)
- Hourly: 12 snapshots (12 hours)
- Daily: 7 snapshots (1 week)
- No monthly or yearly retention

### Customizing Policies

Edit `/etc/sanoid/sanoid.conf`:

```ini
# Add custom dataset
[rpool/USERDATA/myproject]
    use_template = custom_project
    recursive = no

# Define custom template
[template_custom_project]
    frequently = 4      # Every 15 minutes (4 per hour)
    hourly = 72         # 3 days
    daily = 180         # 6 months
    monthly = 24        # 2 years
    yearly = 5          # 5 years
    autosnap = yes
    autoprune = yes
```

### Enable and Start Sanoid

```bash
# Enable the systemd timer
sudo systemctl enable sanoid.timer

# Start the timer
sudo systemctl start sanoid.timer

# Check status
sudo systemctl status sanoid.timer

# View next scheduled run
systemctl list-timers sanoid.timer
```

### Manual Sanoid Execution

```bash
# Run sanoid manually (for testing)
sudo sanoid --verbose

# Dry run (show what would be done)
sudo sanoid --verbose --dry-run

# Take snapshots only (no pruning)
sudo sanoid --take-snapshots

# Prune only (no new snapshots)
sudo sanoid --prune-snapshots
```

## Manual Snapshot Management

### Creating Snapshots

```bash
# Single dataset snapshot
sudo zfs snapshot rpool/ROOT/pop@manual-backup-$(date +%Y%m%d)

# Recursive snapshot (all child datasets)
sudo zfs snapshot -r rpool/ROOT/pop@before-upgrade

# Snapshot with custom name
sudo zfs snapshot rpool/USERDATA/home@important-milestone
```

### Listing Snapshots

```bash
# List all snapshots
zfs list -t snapshot

# List snapshots for specific dataset
zfs list -t snapshot -r rpool/ROOT/pop

# Sort by creation time
zfs list -t snapshot -S creation

# Show snapshot sizes
zfs list -t snapshot -o name,used,refer
```

### Deleting Snapshots

```bash
# Delete single snapshot
sudo zfs destroy rpool/ROOT/pop@old-snapshot

# Delete recursive snapshot
sudo zfs destroy -r rpool/ROOT/pop@old-recursive

# Delete range of snapshots
sudo zfs destroy rpool/ROOT/pop@snapshot1%snapshot10

# Dry run (show what would be deleted)
sudo zfs destroy -nv rpool/ROOT/pop@snapshot1%snapshot10
```

### Snapshot Properties

```bash
# View snapshot properties
zfs get all rpool/ROOT/pop@snapshot-name

# Get snapshot creation time
zfs get creation rpool/ROOT/pop@snapshot-name

# Get snapshot size
zfs get used rpool/ROOT/pop@snapshot-name
```

## APT Integration

### Automatic Snapshots on Package Operations

The system automatically creates snapshots before APT operations:

```bash
# When you run apt upgrade, a snapshot is created automatically
sudo apt upgrade

# Snapshots are named: @apt_YYYY-MM-DD_HH:MM:SS
zfs list -t snapshot | grep '@apt_'
```

### Configuration

APT hooks are configured in `/etc/apt/apt.conf.d/80-zfs-snapshot`.

The helper script is at `/usr/local/bin/apt-zfs-snapshot`.

### Manual APT Snapshot

```bash
# Create snapshot before manual package operation
sudo zfs snapshot -r rpool/ROOT/pop@before-package-install
sudo apt install some-package
```

## Syncoid - Remote Replication

### Installing Syncoid

Syncoid is included with sanoid:

```bash
# Already installed with sanoid package
which syncoid
```

### Basic Replication

```bash
# Replicate to remote system via SSH
syncoid rpool/USERDATA/home user@backup-server:backup/home

# Replicate with compression
syncoid --compress=lz4 rpool/USERDATA/home user@backup-server:backup/home

# Replicate recursively
syncoid -r rpool/USERDATA user@backup-server:backup/USERDATA
```

### Automated Backup Script

Create `/usr/local/bin/zfs-backup.sh`:

```bash
#!/bin/bash
set -e

BACKUP_SERVER="user@backup.example.com"
BACKUP_POOL="backup"

# Sync root filesystem
syncoid --no-privilege-elevation \
    rpool/ROOT/pop \
    "$BACKUP_SERVER:$BACKUP_POOL/pop-root"

# Sync user data
syncoid --no-privilege-elevation -r \
    rpool/USERDATA \
    "$BACKUP_SERVER:$BACKUP_POOL/pop-userdata"

echo "Backup completed: $(date)"
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/zfs-backup.sh
```

### Scheduled Backups with Systemd

Create `/etc/systemd/system/zfs-backup.service`:

```ini
[Unit]
Description=ZFS Remote Backup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/zfs-backup.sh
User=root

[Install]
WantedBy=multi-user.target
```

Create `/etc/systemd/system/zfs-backup.timer`:

```ini
[Unit]
Description=Daily ZFS Remote Backup
Requires=zfs-backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Enable the timer:
```bash
sudo systemctl enable zfs-backup.timer
sudo systemctl start zfs-backup.timer
```

### Local External Disk Backup

```bash
# Attach external USB drive with ZFS pool 'backup'
sudo zpool import backup

# Replicate datasets
syncoid -r rpool/USERDATA backup/userdata-backup

# Export pool when done
sudo zpool export backup
```

## Pre-Boot Snapshots

The system automatically creates snapshots before reboot/shutdown.

### Configuration

Service: `/etc/systemd/system/zfs-pre-boot-snapshot.service`
Script: `/usr/local/bin/zfs-pre-boot-snapshot`

### Manual Pre-Boot Snapshot

```bash
sudo /usr/local/bin/zfs-pre-boot-snapshot
```

### Viewing Pre-Boot Snapshots

```bash
zfs list -t snapshot | grep '@pre-boot_'
```

## Best Practices

### 1. Snapshot Strategy

- **Frequent**: For critical data that changes often
- **Regular**: For system state (daily/weekly)
- **Before Changes**: Always snapshot before major changes
- **Long-term**: Monthly/yearly for compliance or archival

### 2. Retention Policies

Balance disk space with recovery needs:
```
Aggressive: hourly(24), daily(7), monthly(3)
Balanced:   hourly(24), daily(30), monthly(6), yearly(1)
Conservative: hourly(48), daily(90), monthly(12), yearly(2)
```

### 3. Monitoring Snapshot Space

```bash
# Check total space used by snapshots
zfs list -o space

# Check space used by specific dataset snapshots
zfs get referenced,used,usedbysnaps rpool/ROOT/pop

# Find snapshots using most space
zfs list -t snapshot -o name,used -s used | tail -20
```

### 4. Snapshot Lifecycle

1. **Creation**: Automatic (sanoid) or manual
2. **Verification**: Periodically test snapshot restore
3. **Pruning**: Let sanoid handle based on policy
4. **Backup**: Replicate important snapshots off-site (syncoid)

### 5. Don't Rely Only on Snapshots

Snapshots are NOT backups:
- They exist on the same pool
- Pool failure = snapshot loss
- Accidental `zpool destroy` = everything gone

Always maintain off-site backups using syncoid.

## Troubleshooting

### Sanoid Not Taking Snapshots

```bash
# Check sanoid timer status
systemctl status sanoid.timer

# Check sanoid service logs
journalctl -u sanoid.service

# Verify configuration syntax
sudo sanoid --configdir=/etc/sanoid --verbose --dry-run
```

### Too Many Snapshots

```bash
# Count snapshots per dataset
zfs list -t snapshot | awk '{print $1}' | cut -d@ -f1 | sort | uniq -c

# Aggressively prune old snapshots
sudo sanoid --prune-snapshots --verbose
```

### Snapshot Space Usage

```bash
# Identify snapshots with high space usage
zfs list -t snapshot -o name,used -s used

# Delete specific high-usage snapshots
sudo zfs destroy rpool/ROOT/pop@old-large-snapshot
```

## See Also

- [Recovery Guide](ZFS-RECOVERY.md) - Using snapshots for recovery
- [Installation Guide](ZFS-INSTALL.md) - Initial setup
- [Sanoid Documentation](https://github.com/jimsalterjrs/sanoid)
