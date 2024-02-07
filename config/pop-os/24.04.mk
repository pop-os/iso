DISTRO_NAME=Pop_OS

ifeq ($(NVIDIA),1)
DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64 Nvidia
else
DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64 Intel
endif

# Show splash screen
DISTRO_PARAMS+=quiet splash

GNOME_INITIAL_SETUP_STAMP=21.04

# DEB822 format system repositories, comment out to disable
DEB822:=1
APPS_URI:=http://apt.pop-os.org/proprietary

# Repositories to be present in installed system
RELEASE_URI:=http://apt.pop-os.org/release

# Use proposed repositories instead, if requested
ifeq ($(PROPOSED),1)
RELEASE_URI:=http://apt.pop-os.org/staging/master
endif

# Packages to install
DISTRO_PKGS=\
	systemd \
	pop-desktop

# Packages to install after (to avoid dependency issues)
POST_DISTRO_PKGS=\
	system76-acpi-dkms \
	system76-dkms \
	system76-io-dkms

ifeq ($(NVIDIA),1)
DISTRO_PARAMS+=modules_load=nvidia
DISTRO_PARAMS+=nvidia-drm.modeset=0
POST_DISTRO_PKGS+=\
	amd-ppt-bin \
	nvidia-driver-525
endif

# Staging branches to use when building ISO.
# No values is the same as building from release
# `branch-name` is equivalent to `apt-manage add popdev:branch-name -y`
#TODO: REMOVE AFTER https://github.com/pop-os/distinst-v2/pull/3 IS MERGED
STAGING_BRANCHES=distinst-v2-dependencies

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	distinst \
	expect \
	gparted \
	pop-installer \
	pop-installer-casper

# Packages to remove from installed system (usually installed as Recommends)
RM_PKGS=\
	ibus-mozc \
	imagemagick-6.q16 \
	irqbalance \
	mozc-utils-gui \
	pop-installer-session \
	snapd \
	ubuntu-advantage-tools \
	ubuntu-minimal \
	ubuntu-session \
	ubuntu-wallpapers \
	unattended-upgrades \
	xul-ext-ubufox \
	yaru-theme-gnome-shell

# Packages not installed, but that may need to be discovered by the installer
MAIN_POOL=\
	at \
	dfu-programmer \
	efibootmgr \
	ethtool \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	grub-pc \
	grub-pc-bin \
	grub-gfxpayload-lists \
	hdparm \
	kernelstub \
	libfl2 \
	libx86-1 \
	lm-sensors \
	pm-utils \
	pop-hp-vendor \
	pop-hp-vendor-dkms \
	pop-hp-wallpapers \
	postfix \
	powermgmt-base \
	python3-debian \
	python3-distro \
	python3-evdev \
	python3-systemd \
	system76-driver \
	system76-firmware-daemon \
	system76-oled \
	system76-wallpapers \
	vbetool \
	xbacklight

ifeq ($(NVIDIA),1)
MAIN_POOL+=\
	system76-driver-nvidia
endif

# Additional pool packages from the restricted set of packages
RESTRICTED_POOL=\
	amd64-microcode \
	intel-microcode \
	iucode-tool

ifeq ($(HP),1)
DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64 HP
POST_DISTRO_PKGS+=\
	pop-hp-vendor \
	pop-hp-vendor-dkms \
	pop-hp-wallpapers
RM_PKGS+=\
	pop-wallpapers
LIVE_PKGS+=\
	dbus-x11
endif
