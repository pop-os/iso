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
endif

UBUNTU_REPOS=\
	main restricted universe multiverse \
	'deb http://us.archive.ubuntu.com/ubuntu/ $(UBUNTU_CODE)-updates main restricted universe multiverse' \
	'deb http://us.archive.ubuntu.com/ubuntu/ $(UBUNTU_CODE)-backports main restricted universe multiverse' \
	'deb http://us.archive.ubuntu.com/ubuntu/ $(UBUNTU_CODE)-security main restricted universe multiverse'
