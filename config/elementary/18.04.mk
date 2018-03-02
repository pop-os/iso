DISTRO_NAME=elementary

# Repositories to be present in installed system
DISTRO_REPOS=\
	$(UBUNTU_REPOS) \
	ppa:elementary-os/os-patches \
	ppa:elementary-os/stable

ifeq ($(PROPOSED),1)
DISTRO_REPOS+=\
	$(UBUNTU_PROPOSED) \
	ppa:elementary-os/daily
endif

# Packages to install
DISTRO_PKGS=\
	linux-generic \
	linux-signed-generic \
	ubuntu-minimal \
	ubuntu-standard \
	elementary-desktop \
	$(LANGUAGE_PKGS)

ifeq ($(NVIDIA),1)
DISTRO_PKGS+=\
	nvidia-384
endif

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	gparted \
	jfsutils \
	lupin-casper \
	mokutil \
	mtools \
	reiserfsprogs \
	ubiquity-frontend-gtk \
	ubiquity-slideshow-ubuntu \
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
	grub-efi \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	libatomic1 \
	libc6-dev \
	libc-dev-bin \
	libcilkrts5 \
	libfakeroot \
	libitm1 \
	liblsan0 \
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
