DISTRO_VERSION?=17.10

DISTRO_EPOCH?=$(shell date +%s)
DISTRO_DATE?=$(shell date +%Y%m%d)

DISTRO_NAME=Pop_OS
DISTRO_CODE=pop-os

ISO_NAME?=$(DISTRO_CODE)

GPG_NAME?=`id -un`

# Include automatic variables
include mk/automatic.mk

# Include Ubuntu definitions
include mk/ubuntu.mk

# Language packages
include mk/language.mk

# Repositories to be present in installed system
DISTRO_REPOS=\
	$(UBUNTU_REPOS) \
	ppa:system76/pop

ifeq ($(PROPOSED),1)
DISTRO_REPOS+=\
	ppa:system76/proposed
endif

# Packages to install
DISTRO_PKGS=\
	linux-generic \
	linux-signed-generic \
	ubuntu-minimal \
	ubuntu-standard \
	pop-desktop \
	$(LANGUAGE_PKGS)

ifeq ($(NVIDIA),1)
DISTRO_PKGS+=\
	nvidia-384
endif

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	jfsutils \
	lupin-casper \
	mokutil \
	mtools \
	reiserfsprogs \
	ubiquity-frontend-gtk \
	ubiquity-slideshow-pop \
	xfsprogs

# Packages to remove from installed system (usually installed as Recommends)
RM_PKGS=\
	imagemagick-6.q16 \
	xul-ext-ubufox

# Packages not installed, but that may need to be discovered by the installer
MAIN_POOL=\
	b43-fwcutter \
	dkms \
	fakeroot \
	gcc \
	gcc-7 \
	grub-efi \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	libasan4 \
	libatomic1 \
	libc6-dev \
	libc-dev-bin \
	libcilkrts5 \
	libfakeroot \
	libgcc-7-dev \
	libitm1 \
	liblsan0 \
	libmpx2 \
	libquadmath0 \
	libtsan0 \
	libubsan0 \
	libuniconf4.6 \
	libwvstreams4.6-base \
	libwvstreams4.6-extras \
	linux-libc-dev \
	lupin-support \
	make \
	manpages-dev \
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
