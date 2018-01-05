DISTRO_VERSION?=18.04

DISTRO_EPOCH?=$(shell date +%s)
DISTRO_DATE?=$(shell date +%Y%m%d)

DISTRO_NAME=Pop_OS
DISTRO_CODE=pop-os

ISO_NAME?=$(DISTRO_CODE)

GPG_NAME?=`id -un`

PROPOSED?=1
NVIDIA?=0

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
	ppa:system76/proposed \
	'deb [arch=amd64] ftp://10.17.75.74/repos/develop artful main'
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
	distinst \
	io.elementary.installer

# Packages to remove from installed system (usually installed as Recommends)
RM_PKGS=\
	imagemagick-6.q16 \
	io.elementary.installer-session \
	xul-ext-ubufox

# Packages not installed, but that may need to be discovered by the installer
MAIN_POOL=\
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed

# Additional pool packages from the restricted set of packages
RESTRICTED_POOL=\
	intel-microcode \
	iucode-tool
