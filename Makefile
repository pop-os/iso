# Configuration settings
DISTRO_CODE?=pop-os
DISTRO_VERSION?=18.04

DISTRO_EPOCH?=$(shell date +%s)
DISTRO_DATE?=$(shell date +%Y%m%d)

ISO_NAME?=$(DISTRO_CODE)_$(DISTRO_VERSION)

GPG_NAME?=`id -un`

PROPOSED?=0
NVIDIA?=0

# Include automatic variables
include mk/automatic.mk

# Include Ubuntu definitions
include mk/ubuntu.mk

# Language packages
include mk/language.mk

# Include configuration file
include config/$(DISTRO_CODE)/$(DISTRO_VERSION).mk

# Standard target - build the ISO
iso: $(ISO)

tar: $(TAR)

usb: $(USB)

# Complete target - build zsync file, SHA256SUMS, and GPG signature
all: $(ISO) $(ISO).zsync $(BUILD)/SHA256SUMS $(BUILD)/SHA256SUMS.gpg

# Clean target
include mk/clean.mk

# QEMU targets
include mk/qemu.mk

# Chroot targets
include mk/chroot.mk

# Update targets
include mk/update.mk

# ISO targets
include mk/iso.mk
