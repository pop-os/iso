# Description of upstream Ubuntu
ifeq ($(DISTRO_VERSION),16.04)
	UBUNTU_CODE=xenial
	UBUNTU_NAME=Xenial Xerus
else ifeq ($(DISTRO_VERSION),17.04)
	UBUNTU_CODE=zesty
	UBUNTU_NAME=Zesty Zapus
else ifeq ($(DISTRO_VERSION),17.10)
	UBUNTU_CODE=artful
	UBUNTU_NAME=Artful Aardvark
else ifeq ($(DISTRO_VERSION),18.04)
	UBUNTU_CODE=bionic
	UBUNTU_NAME=Bionic Beaver
else ifeq ($(DISTRO_VERSION),18.10)
	UBUNTU_CODE=cosmic
	UBUNTU_NAME=Cosmic
endif

UBUNTU_COMPONENTS=\
	main \
	restricted \
	universe \
	multiverse

UBUNTU_MIRROR=http://us.archive.ubuntu.com/ubuntu/

UBUNTU_FAST_MIRROR=http://mirror.math.princeton.edu/pub/ubuntu/

UBUNTU_REPOS=\
	-'deb $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE) $(UBUNTU_COMPONENTS)' \
	-'deb $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-updates $(UBUNTU_COMPONENTS)' \
	-'deb $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-security $(UBUNTU_COMPONENTS)' \
	-'deb $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-backports $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE) $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-updates $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-security $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-backports $(UBUNTU_COMPONENTS)'

UBUNTU_PROPOSED=\
	-'deb $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-proposed $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-proposed $(UBUNTU_COMPONENTS)'
