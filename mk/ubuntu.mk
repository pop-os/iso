# Description of upstream Ubuntu
ifeq ($(DISTRO_VERSION),22.04)
UBUNTU_CODE:=jammy
UBUNTU_NAME:=Jammy Jellyfish
else ifeq ($(DISTRO_VERSION),24.04)
UBUNTU_CODE:=noble
UBUNTU_NAME:=Noble Numbat
else ifeq ($(DISTRO_VERSION),26.04)
UBUNTU_CODE:=resolute
UBUNTU_NAME:=Resolute Raccoon
else
$(error unknown DISTRO_VERSION $(DISTRO_VERSION))
endif

ifeq ($(DISTRO_ARCH),amd64)
UBUNTU_MIRROR:=http://apt.pop-os.org/ubuntu
else ifeq ($(DISTRO_ARCH),arm64)
UBUNTU_MIRROR:=http://ports.ubuntu.com/ubuntu-ports
else
$(error unknown DISTRO_ARCH $(DISTRO_ARCH))
endif
UBUNTU_KEY=/etc/apt/trusted.gpg.d/ubuntu-keyring-2018-archive.gpg

UBUNTU_COMPONENTS:=\
	main \
	restricted \
	universe \
	multiverse

UBUNTU_REPOS:=\
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE) $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-security $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-updates $(UBUNTU_COMPONENTS)' \
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-backports $(UBUNTU_COMPONENTS)'

UBUNTU_PROPOSED:=\
	'deb $(UBUNTU_MIRROR) $(UBUNTU_CODE)-proposed $(UBUNTU_COMPONENTS)'
