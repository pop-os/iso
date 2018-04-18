DISTRO_NAME=Pop_OS

# Repositories to be present in installed system
DISTRO_REPOS=\
	$(UBUNTU_REPOS) \
	ppa:system76/pop

ifeq ($(PROPOSED),1)
DISTRO_REPOS+=\
	$(UBUNTU_PROPOSED) \
	ppa:system76/proposed
endif

# Packages to install
DISTRO_PKGS=\
	linux-generic \
	linux-signed-generic \
	ubuntu-minimal \
	ubuntu-standard \
	pop-desktop

ifeq ($(NVIDIA),1)
DISTRO_PKGS+=\
	nvidia-driver-390
endif

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	distinst \
	gparted \
	pop-installer \
	pop-installer-casper \
	pop-shop-casper

# Packages to remove from installed system (usually installed as Recommends)
RM_PKGS=\
	imagemagick-6.q16 \
	plymouth \
	pop-installer-session \
	tracker \
	unattended-upgrades \
	xul-ext-ubufox

# Packages not installed, but that may need to be discovered by the installer
MAIN_POOL=\
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	kernelstub

# Additional pool packages from the restricted set of packages
RESTRICTED_POOL=\
	intel-microcode \
	iucode-tool
