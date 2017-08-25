DISTRO_VERSION?=16.04

DISTRO_EPOCH?=$(shell date +%s)

DISTRO_DATE?=$(shell date +%Y%M%d)

DISTRO_NAME=elementary

DISTRO_CODE=elementary

# Include automatic variables
include mk/automatic.mk

# Include Ubuntu definitions
include mk/ubuntu.mk

# Language packages
include mk/language.mk

# Repositories to be present in installed system
DISTRO_REPOS=\
	$(UBUNTU_REPOS) \
	ppa:elementary-os/os-patches \
	ppa:elementary-os/stable

# Packages to install
DISTRO_PKGS=\
	elementary-minimal \
	elementary-standard \
	elementary-desktop

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	linux-generic \
	linux-signed-generic \
	lupin-casper \
	mokutil \
	mtools \
	reiserfsprogs \
	ubiquity-frontend-gtk \
	xfsprogs \
	$(LANGUAGE_PKGS)

# Packages to remove from installed system (usually installed as Recommends)
RM_PKGS=\
	imagemagick-6.q16

# Packages not installed, but that may need to be discovered by the installer
MAIN_POOL=\
	b43-fwcutter \
	dkms \
	grub-efi \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	libuniconf4.6 \
	libwvstreams4.6-base \
	libwvstreams4.6-extras \
	lupin-support \
	mouseemu \
	oem-config \
	oem-config-gtk \
	oem-config-slideshow-ubuntu \
	setserial \
	shim \
	shim-signed \
	user-setup \
	wvdial

# Additional pool packages from the restricted set of packages
RESTRICTED_POOL=\
	bcmwl-kernel-source \
	intel-microcode \
	iucode-tool
