DISTRO_NAME=Pop_OS

# Repositories to be present in installed system
DISTRO_REPOS=\
	$(UBUNTU_REPOS) \
	ppa:system76/pop

# Add proposed repositories
ifeq ($(PROPOSED),1)
DISTRO_REPOS+=\
	$(UBUNTU_PROPOSED) \
	ppa:system76/proposed
endif

# Add binary repository without source
DISTRO_REPOS+=\
	-- \
	'deb http://apt.pop-os.org/proprietary $(UBUNTU_CODE) main'

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
	expect \
	gparted \
	pop-installer \
	pop-installer-casper \
	pop-shop-casper

# Packages to remove from installed system (usually installed as Recommends)
RM_PKGS=\
	imagemagick-6.q16 \
	pop-installer-session \
	tracker \
	unattended-upgrades \
	xul-ext-ubufox

# Packages not installed, but that may need to be discovered by the installer
MAIN_POOL=\
	ethtool \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	kernelstub \
	libx86-1 \
	pm-utils \
	python3-evdev \
	system76-dkms \
	system76-driver \
	system76-firmware-daemon \
	system76-wallpapers \
	vbetool \
	xbacklight

# Additional pool packages from the restricted set of packages
RESTRICTED_POOL=\
	amd64-microcode \
	intel-microcode \
	iucode-tool
