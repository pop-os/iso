# Description of upstream Ubuntu
ifeq ($(DISTRO_VERSION),16.04)
	UBUNTU_CODE:=xenial
	UBUNTU_NAME:=Xenial Xerus
else ifeq ($(DISTRO_VERSION),17.04)
	UBUNTU_CODE:=zesty
	UBUNTU_NAME:=Zesty Zapus
else ifeq ($(DISTRO_VERSION),17.10)
	UBUNTU_CODE:=artful
	UBUNTU_NAME:=Artful Aardvark
else ifeq ($(DISTRO_VERSION),18.04)
	UBUNTU_CODE:=bionic
	UBUNTU_NAME:=Bionic Beaver
else ifeq ($(DISTRO_VERSION),18.10)
	UBUNTU_CODE:=cosmic
	UBUNTU_NAME:=Cosmic Cuttlefish
else ifeq ($(DISTRO_VERSION),19.04)
	UBUNTU_CODE:=disco
	UBUNTU_NAME:=Disco Dingo
else ifeq ($(DISTRO_VERSION),19.10)
	UBUNTU_CODE:=eoan
	UBUNTU_NAME:=Eoan Ermine
else ifeq ($(DISTRO_VERSION),20.04)
	UBUNTU_CODE:=focal
	UBUNTU_NAME:=Focal Fossa
else ifeq ($(DISTRO_VERSION),20.10)
	UBUNTU_CODE:=groovy
	UBUNTU_NAME:=Groovy Gorilla
else ifeq ($(DISTRO_VERSION),21.04)
	UBUNTU_CODE:=hirsute
	UBUNTU_NAME:=Hirsute Hippo
else ifeq ($(DISTRO_VERSION),21.10)
	UBUNTU_CODE:=impish
	UBUNTU_NAME:=Impish Indri
else ifeq ($(DISTRO_VERSION),22.04)
	UBUNTU_CODE:=jammy
	UBUNTU_NAME:=Jammy Jellyfish
endif

UBUNTU_MIRROR:=http://apt.pop-os.org/ubuntu

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
