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
endif

UBUNTU_MIRROR:=http://us.archive.ubuntu.com/ubuntu/

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

ifeq ($(FAST_MIRROR),1)
	UBUNTU_FAST_MIRROR=http://apt.pop-os.org/ubuntu/

	UBUNTU_FAST_COMPONENTS:=$(UBUNTU_COMPONENTS)

	UBUNTU_REPOS:=\
		-'deb [arch=amd64] $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE) $(UBUNTU_FAST_COMPONENTS)' \
		-'deb [arch=amd64] $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-security $(UBUNTU_FAST_COMPONENTS)' \
		-'deb [arch=amd64] $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-updates $(UBUNTU_FAST_COMPONENTS)' \
		-'deb [arch=amd64] $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-backports $(UBUNTU_FAST_COMPONENTS)' \
		$(UBUNTU_REPOS)

	UBUNTU_PROPOSED:=\
		-'deb [arch=amd64] $(UBUNTU_FAST_MIRROR) $(UBUNTU_CODE)-proposed $(UBUNTU_FAST_COMPONENTS)' \
		$(UBUNTU_PROPOSED)
endif
