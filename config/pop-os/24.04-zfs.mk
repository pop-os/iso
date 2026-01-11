# Pop!_OS 24.04 with ZFS and ZFSBootMenu Support
# This extends the base 24.04 configuration with ZFS-specific packages

# Include base 24.04 configuration
include config/pop-os/24.04.mk

# ZFS-specific packages for root filesystem support
ZFS_PKGS=\
	zfsutils-linux \
	zfs-initramfs \
	zfs-dkms \
	zfs-zed

# ZFSBootMenu dependencies for boot environment management
ZBM_PKGS=\
	dracut-core \
	fzf \
	kexec-tools \
	efibootmgr

# Snapshot automation tools
SNAPSHOT_PKGS=\
	sanoid \
	lzop \
	mbuffer \
	pv

# Add ZFS packages to distribution packages
DISTRO_PKGS+=\
	$(ZFS_PKGS) \
	$(ZBM_PKGS)

# Add snapshot tools to live environment
LIVE_PKGS+=\
	$(SNAPSHOT_PKGS)

# Add ZFS recovery tools to main pool
MAIN_POOL+=\
	zfs-auto-snapshot \
	zfs-initramfs

# Override volume label to indicate ZFS support
ifeq ($(NVIDIA),1)
DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) ZFS NVIDIA
else
DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) ZFS
endif
