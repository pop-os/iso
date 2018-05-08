DISTRO_NAME=elementary

# Repositories to be present in installed system
DISTRO_REPOS=\
	$(UBUNTU_REPOS) \
	ppa:elementary-os/daily

ifeq ($(PROPOSED),1)
DISTRO_REPOS+=\
	$(UBUNTU_PROPOSED)
endif

# Packages to install
DISTRO_PKGS=\
	linux-generic \
	linux-signed-generic \
	ubuntu-minimal \
	ubuntu-standard \
	elementary-desktop

ifeq ($(NVIDIA),1)
DISTRO_PKGS+=\
	nvidia-384
endif

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	distinst \
	gparted \
	io.elementary.installer

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
	grub-efi \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	kernelstub

# Additional pool packages from the restricted set of packages
RESTRICTED_POOL=\
	intel-microcode \
	iucode-tool
