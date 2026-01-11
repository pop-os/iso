# Pop!\_OS ISO production with ZFS support

This repository contains the tools necessary for building Pop!\_OS ISOs with ZFS root filesystem and ZFSBootMenu support.

## Features

- **ZFS root filesystem** with native encryption support
- **ZFSBootMenu** for advanced boot environment management
- **Automated snapshot tooling** (sanoid/syncoid) for backup and recovery
- **COSMIC desktop** integration
- **Reproducible build system** using containers
- Optimized for System76 hardware (Meerkat 10, Serval WS)

## Quick Start

### Building the ZFS-enabled ISO

```sh
# Install dependencies
./deps.sh

# Build ZFS-enabled Pop!_OS 24.04 ISO
make DISTRO_VERSION=24.04 iso

# Build with NVIDIA drivers
make DISTRO_VERSION=24.04 NVIDIA=1 iso
```

The built ISO will be at: `build/pop-os/24.04/amd64/pop-os_24.04_amd64_zfs.iso`

### Installing Pop!_OS with ZFS

Boot from the ZFS-enabled ISO and follow the [installation guide](docs/ZFS-INSTALL.md).

## Requirements

### Build Dependencies

First, import the Pop!\_OS ISO signing key:

```sh
gpg --recv-keys 204DD8AEC33A7AFF
```

Then install build dependencies:

```sh
./deps.sh
```

This installs:
- debootstrap, germinate
- squashfs-tools, xorriso, zsync
- qemu-kvm, ovmf
- grub-efi, isolinux

### For ISO Signing (Optional)

Generate your own GPG key:

```sh
gpg --full-gen-key
gpg --send-keys --keyserver keyserver.ubuntu.com ${YOUR_KEY_ID_HERE}
```

## Building

### Standard Build

```sh
# Build Pop!_OS 24.04 ZFS ISO (default)
make iso

# Build for specific version
make DISTRO_VERSION=24.04 iso

# Build for specific architecture
make DISTRO_ARCH=amd64 iso
make DISTRO_ARCH=arm64 iso
```

### Build Options

```sh
# With NVIDIA drivers
make NVIDIA=1 iso

# HP variant
make HP=1 iso

# Using proposed repositories
make PROPOSED=1 iso

# Combined options
make DISTRO_VERSION=24.04 NVIDIA=1 iso
```

### Testing

```sh
# Test in QEMU (UEFI mode)
make qemu_uefi

# Test in QEMU (BIOS mode, amd64 only)
make qemu_bios

# Write to USB with Popsicle
make popsicle
```

### Cleaning

```sh
# Clean build artifacts (keeps debootstrap cache)
make clean

# Complete clean (removes everything)
make distclean
```

## Reproducible Builds

### Using Containers

Build using Docker/Podman for reproducible results:

```sh
# Build the container image
docker build -t pop-iso-builder -f Containerfile .

# Build ISO in container
docker run --rm --privileged \
    -v $(pwd):/build \
    pop-iso-builder \
    make iso
```

### CI/CD

GitHub Actions automatically builds ISOs on push. See `.github/workflows/build-iso.yml`.

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[ZFS Installation Guide](docs/ZFS-INSTALL.md)** - Installing Pop!_OS with ZFS
- **[ZFS Recovery Guide](docs/ZFS-RECOVERY.md)** - Recovery procedures and snapshot rollback
- **[Snapshot Management](docs/SNAPSHOT-MANAGEMENT.md)** - Using sanoid/syncoid for automated snapshots
- **[Building Guide](docs/BUILDING.md)** - Detailed build instructions and customization
- **[Hardware Notes](docs/HARDWARE-NOTES.md)** - System76 hardware-specific information

## What's Included

### ZFS Components

- **zfsutils-linux** - Core ZFS utilities
- **zfs-initramfs** - ZFS support in initramfs
- **zfs-dkms** - ZFS kernel modules
- **zfs-zed** - ZFS Event Daemon

### ZFSBootMenu

- **dracut-core** - Initramfs builder for ZFSBootMenu
- **zfsbootmenu** - Boot environment manager
- **kexec-tools** - Fast kernel switching
- **fzf** - Fuzzy finder for boot menu

### Snapshot Automation

- **sanoid** - Policy-driven snapshot management
- **syncoid** - ZFS replication tool
- **lzop, mbuffer, pv** - Snapshot utilities

### Configuration Templates

- `data/zfs/pool-layout.yaml` - Default ZFS dataset layout
- `data/zfs/sanoid.conf.template` - Snapshot policies
- `data/zfs/zfsbootmenu.yaml.template` - ZFSBootMenu configuration
- APT hooks for automatic snapshots before package operations
- Systemd services for pre-boot snapshots

## ZFS Dataset Layout

The default installation creates:

```
rpool/                         # Root pool
├── ROOT/
│   └── pop/                   # Boot environment (/)
├── USERDATA/
│   └── home/                  # User home (/home)
├── var/
│   ├── cache/                 # Excluded from snapshots
│   ├── log/                   # Separate snapshot policy
│   └── tmp/                   # No snapshots
└── reserved/                  # 10% reserved space
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

See [LICENSE.md](LICENSE.md).

## Support

- [Pop!_OS Community](https://pop.system76.com/)
- [System76 Support](https://support.system76.com/)
- [GitHub Issues](https://github.com/chainofreasoning/pop-os-iso-with-zfs/issues)
