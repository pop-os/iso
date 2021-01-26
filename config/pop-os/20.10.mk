DISTRO_NAME=Pop_OS

ifeq ($(NVIDIA),1)
DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64 Nvidia
else
DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64 Intel
endif

# DEB822 format system repositories, comment out to disable
DEB822:=1
APPS_URI:=http://apt.pop-os.org/proprietary

# Repositories to be present in installed system
DISTRO_REPOS=\
	ppa:system76/pop

# Add proposed repositories
ifeq ($(PROPOSED),1)
DISTRO_REPOS+=\
	ppa:system76/proposed
endif

# Add repositories without source
DISTRO_REPOS+=--

# Packages to install
DISTRO_PKGS=\
	linux-system76 \
	ubuntu-minimal \
	ubuntu-standard \
	pop-desktop

# Packages to install after (to avoid dependency issues)
POST_DISTRO_PKGS=\
	system76-acpi-dkms \
	system76-dkms \
	system76-io-dkms

ifeq ($(NVIDIA),1)
DISTRO_PARAMS+=modules_load=nvidia
POST_DISTRO_PKGS+=\
	amd-ppt-bin \
	nvidia-driver-460
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
	mozc-utils-gui \
	pop-installer-session \
	snapd \
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
	kernelstub \
	libfl2 \
	libx86-1 \
	pm-utils \
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
