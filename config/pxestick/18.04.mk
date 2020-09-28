DISTRO_NAME=PXEstick

# Repositories to be present in installed system
DISTRO_REPOS=$(UBUNTU_REPOS)

DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64

# Packages to install
DISTRO_PKGS=\
	linux-generic \
	ubuntu-minimal \
	ubuntu-standard

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	pxe-kexec

# No language packs required
LANGUAGES=
