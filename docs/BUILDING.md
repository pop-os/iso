# Building Pop!_OS ZFS ISO

This guide covers building a reproducible Pop!_OS 24.04 ISO with ZFS and ZFSBootMenu support.

## Prerequisites

### System Requirements

- Ubuntu 24.04 or Pop!_OS 24.04 (host system)
- At least 32GB free disk space
- At least 8GB RAM
- Sudo privileges
- Fast internet connection

### Software Dependencies

Install build dependencies:

```bash
./deps.sh
```

This installs:
- debootstrap
- germinate
- isolinux
- mtools
- ovmf
- qemu-kvm
- qemu-user-static
- squashfs-tools
- xorriso
- zsync
- grub-efi-amd64-signed (on amd64)
- grub-pc-bin (on amd64)

## Building the ISO

### Quick Start

Build the default ZFS-enabled ISO:

```bash
# Set version to build ZFS variant
make DISTRO_VERSION=24.04 CONFIG=24.04-zfs iso
```

Or explicitly:

```bash
make DISTRO_CODE=pop-os DISTRO_VERSION=24.04 iso
```

### Build Options

#### Architecture

```bash
# AMD64 (default)
make DISTRO_ARCH=amd64 iso

# ARM64
make DISTRO_ARCH=arm64 iso
```

#### NVIDIA Drivers

Include NVIDIA drivers in the ISO:

```bash
make NVIDIA=1 iso
```

#### HP Variant

For HP-branded systems:

```bash
make HP=1 iso
```

#### Proposed Repositories

Use proposed/testing repositories:

```bash
make PROPOSED=1 iso
```

### Combined Options

```bash
# ZFS ISO with NVIDIA drivers for AMD64
make DISTRO_VERSION=24.04 DISTRO_ARCH=amd64 NVIDIA=1 iso

# Complete build with all options
make DISTRO_CODE=pop-os \
     DISTRO_VERSION=24.04 \
     DISTRO_ARCH=amd64 \
     NVIDIA=1 \
     iso
```

## Build Process

The build happens in stages:

### 1. Debootstrap Stage

Creates base Ubuntu system:
```bash
# Manually trigger
make build/pop-os/24.04/amd64/debootstrap
```

### 2. Chroot Stage

Installs Pop!_OS packages and ZFS:
```bash
make build/pop-os/24.04/amd64/chroot
```

Packages installed:
- systemd
- cosmic-desktop
- linux-system76
- zfsutils-linux, zfs-initramfs, zfs-dkms
- dracut-core, kexec-tools
- sanoid (for snapshots)

### 3. Live Environment Stage

Prepares live environment with installer:
```bash
make build/pop-os/24.04/amd64/live
```

### 4. ISO Assembly

Creates the final ISO:
```bash
make build/pop-os/24.04/amd64/pop-os_24.04_amd64.iso
```

## Build Output

### Location

Built ISO is located at:
```
build/pop-os/24.04/amd64/pop-os_24.04_amd64_zfs.iso
```

### Build Artifacts

```
build/pop-os/24.04/amd64/
├── chroot/              # Base system chroot
├── debootstrap/         # Debootstrap cache
├── iso/                 # ISO contents before packing
├── live/                # Live environment filesystem
├── pool/                # Package pool
├── pop-os_24.04_amd64_zfs.iso       # Final ISO
├── pop-os_24.04_amd64_zfs.iso.zsync # Zsync file
├── SHA256SUMS           # Checksums
└── SHA256SUMS.gpg       # GPG signature
```

## Cleaning Build

### Clean ISO Only

Removes ISO and keeps debootstrap/chroot:
```bash
make clean
```

### Full Clean

Removes everything including debootstrap:
```bash
make distclean
```

### Selective Clean

```bash
# Remove just the live environment
sudo rm -rf build/pop-os/24.04/amd64/live

# Remove ISO assembly
sudo rm -rf build/pop-os/24.04/amd64/iso
```

## Testing the ISO

### QEMU (Quick Test)

Test in UEFI mode:
```bash
make qemu_uefi
```

Test in BIOS mode (x86_64 only):
```bash
make qemu_bios
```

### Custom QEMU Options

```bash
# More RAM
qemu-system-x86_64 -m 4G -enable-kvm \
    -bios /usr/share/ovmf/OVMF.fd \
    -cdrom build/pop-os/24.04/amd64/pop-os_24.04_amd64_zfs.iso

# With virtual disk for installation testing
qemu-system-x86_64 -m 8G -enable-kvm \
    -bios /usr/share/ovmf/OVMF.fd \
    -cdrom build/pop-os/24.04/amd64/pop-os_24.04_amd64_zfs.iso \
    -drive file=test-disk.img,format=raw,if=virtio
```

### Create Test Disk

```bash
# Create 64GB virtual disk
qemu-img create -f raw test-disk.img 64G
```

### Popsicle (USB Writer)

Write to USB drive using Pop's USB writer:
```bash
make popsicle
```

## Reproducible Builds

### Using Docker/Podman

Create a Containerfile (see below for full Containerfile):

```bash
# Build container
docker build -t pop-iso-builder -f Containerfile .

# Build ISO in container
docker run --rm --privileged \
    -v $(pwd):/workspace \
    -w /workspace \
    pop-iso-builder \
    make iso
```

### SOURCE_DATE_EPOCH

For reproducible timestamps:

```bash
export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)
make iso
```

### Verify Reproducibility

```bash
# Build 1
make distclean
make iso
sha256sum build/pop-os/24.04/amd64/pop-os_24.04_amd64_zfs.iso > build1.sha256

# Build 2
make distclean
make iso
sha256sum build/pop-os/24.04/amd64/pop-os_24.04_amd64_zfs.iso > build2.sha256

# Compare
diff build1.sha256 build2.sha256
```

## CI/CD Integration

### GitHub Actions

See `.github/workflows/build-iso.yml` for automated builds.

Builds are triggered on:
- Push to main branch
- Pull requests
- Manual workflow dispatch

Artifacts are uploaded for each build.

### Local CI Simulation

```bash
# Run the same commands as CI
./deps.sh
make distclean
make iso
make SHA256SUMS
```

## Customization

### Adding Packages

Edit `config/pop-os/24.04-zfs.mk`:

```makefile
# Add your packages to ZFS_PKGS, ZBM_PKGS, or SNAPSHOT_PKGS
ZFS_PKGS+=\
    your-custom-package
```

### Custom Scripts

Add scripts to `scripts/` directory and integrate them in the build:

```makefile
# In mk/chroot.mk or mk/iso.mk
sudo cp "scripts/your-script.sh" "$@.partial/iso/your-script.sh"
```

### Modifying Boot Parameters

Edit kernel command line in `data/zfs/zfsbootmenu.yaml.template`:

```yaml
Kernel:
  CommandLine: quiet splash your_custom_param=value
```

## Troubleshooting

### Build Fails

```bash
# Check logs
cat build/pop-os/24.04/amd64/debootstrap/debootstrap.log

# Check disk space
df -h

# Verify dependencies
./deps.sh
```

### Permission Issues

The build requires sudo. Ensure:
```bash
# You're in sudoers
sudo -v

# Clean with sudo if needed
sudo make distclean
```

### GPG Key Issues

Import the Pop!_OS signing key:
```bash
gpg --recv-keys 204DD8AEC33A7AFF
```

Generate your own key for signing:
```bash
gpg --full-gen-key
gpg --send-keys --keyserver keyserver.ubuntu.com YOUR_KEY_ID
```

### Out of Space

```bash
# Clean old builds
make distclean

# Remove Docker images if using containers
docker system prune -a
```

### Network Issues

If package downloads fail:
```bash
# Try different mirror
export UBUNTU_MIRROR=http://archive.ubuntu.com/ubuntu
make iso
```

## Advanced Topics

### Chroot Development

Enter the build chroot for testing:

```bash
# Mount the chroot
./scripts/mount.sh build/pop-os/24.04/amd64/chroot

# Enter chroot
sudo chroot build/pop-os/24.04/amd64/chroot /bin/bash

# Test commands, install packages, etc.

# Exit
exit

# Unmount
./scripts/unmount.sh build/pop-os/24.04/amd64/chroot
```

### Partial Rebuilds

Rebuild just specific stages:

```bash
# Rebuild live environment only
sudo rm -rf build/pop-os/24.04/amd64/live
make build/pop-os/24.04/amd64/live

# Rebuild ISO without rebuilding system
sudo rm -rf build/pop-os/24.04/amd64/iso
make iso
```

### Multi-Architecture Builds

Build for multiple architectures:

```bash
# AMD64
make DISTRO_ARCH=amd64 iso

# ARM64 (requires arm64 host or qemu-user-static)
make DISTRO_ARCH=arm64 iso
```

## See Also

- [Installation Guide](ZFS-INSTALL.md)
- [Recovery Guide](ZFS-RECOVERY.md)
- [Hardware Notes](HARDWARE-NOTES.md)
- [Contributing](../CONTRIBUTING.md)
