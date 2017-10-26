BUILD=build/$(DISTRO_VERSION)

ISO=$(BUILD)/$(ISO_NAME).iso
TAR=$(BUILD)/$(ISO_NAME).tar
USB=$(BUILD)/$(ISO_NAME).img

SED=\
	s|DISTRO_NAME|$(DISTRO_NAME)|g; \
	s|DISTRO_CODE|$(DISTRO_CODE)|g; \
	s|DISTRO_VERSION|$(DISTRO_VERSION)|g; \
	s|DISTRO_DATE|$(DISTRO_DATE)|g; \
	s|DISTRO_EPOCH|$(DISTRO_EPOCH)|g; \
	s|DISTRO_REPOS|$(DISTRO_REPOS)|g; \
	s|DISTRO_PKGS|$(DISTRO_PKGS)|g; \
	s|UBUNTU_CODE|$(UBUNTU_CODE)|g; \
	s|UBUNTU_NAME|$(UBUNTU_NAME)|g

XORRISO=$(shell command -v xorriso 2> /dev/null)
ZSYNC=$(shell command -v zsync 2> /dev/null)
SQUASHFS=$(shell command -v mksquashfs 2> /dev/null)

# Ensure that `zsync` is installed already
ifeq (,$(ZSYNC))
$(error zsync not found! Run deps.sh first.)
endif
# Ensure that `xorriso` is installed already
ifeq (,$(XORRISO))
$(error xorriso not found! Run deps.sh first.)
endif
# Ensure that `squashfs` is installed already
ifeq (,$(SQUASHFS))
$(error squashfs-tools not found! Run deps.sh first.)
endif
