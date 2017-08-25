# Description of upstream Ubuntu
ifeq ($(DISTRO_VERSION),16.04)
	UBUNTU_CODE=xenial
	UBUNTU_NAME=Xenial Xerus
	UBUNTU_ISO=http://cdimage.ubuntu.com/ubuntu-gnome/releases/16.04.3/release/ubuntu-gnome-16.04.3-desktop-amd64.iso
else ifeq ($(DISTRO_VERSION),17.04)
	UBUNTU_CODE=zesty
	UBUNTU_NAME=Zesty Zapus
	UBUNTU_ISO=http://cdimage.ubuntu.com/ubuntu-gnome/releases/17.04/release/ubuntu-gnome-17.04-desktop-amd64.iso
else ifeq ($(DISTRO_VERSION),17.10)
	UBUNTU_CODE=artful
	UBUNTU_NAME=Artful Aardvark
	UBUNTU_ISO=http://cdimage.ubuntu.com/ubuntu/daily-live/current/artful-desktop-amd64.iso
endif

UBUNTU_REPOS=\
	main restricted universe multiverse \
	'deb http://us.archive.ubuntu.com/ubuntu/ $(UBUNTU_CODE)-updates main restricted universe multiverse' \
	'deb http://us.archive.ubuntu.com/ubuntu/ $(UBUNTU_CODE)-backports main restricted universe multiverse' \
	'deb http://us.archive.ubuntu.com/ubuntu/ $(UBUNTU_CODE)-security main restricted universe multiverse'
