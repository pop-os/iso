GERMINATE=$(BUILD)/germinate
SEEDS=$(GERMINATE)/seeds/ubuntu.$(UBUNTU_CODE)

$(SEEDS)/distro: FORCE
	mkdir -p $(SEEDS)
	echo "# DISTRO_PKGS" > $@
	for package in $(DISTRO_PKGS); do \
		echo " * $$package" >> $@; \
	done

$(SEEDS)/live: FORCE
	mkdir -p $(SEEDS)
	echo "# LIVE_PKGS" > $@
	for package in $(LIVE_PKGS); do \
		echo " * $$package" >> $@; \
	done

$(SEEDS)/pool: FORCE
	mkdir -p $(SEEDS)
	echo "# MAIN_POOL" > $@
	for package in $(MAIN_POOL); do \
		echo " * $$package" >> $@; \
	done
	echo "# RESTRICTED_POOL" >> $@
	for package in $(RESTRICTED_POOL); do \
		echo " * $$package" >> $@; \
	done

$(SEEDS)/STRUCTURE: FORCE
	mkdir -p $(SEEDS)
	echo "distro:" > $@
	echo "live: distro" >> $@
	echo "pool: live" >> $@

germinate: $(SEEDS)/distro $(SEEDS)/live $(SEEDS)/pool $(SEEDS)/STRUCTURE
	cd $(GERMINATE) && \
	germinate \
	    -S seeds \
	    -s ubuntu.$(UBUNTU_CODE) \
	    -m http://archive.ubuntu.com/ubuntu \
	    -m http://ppa.launchpad.net/system76/pop/ubuntu \
	    -d $(UBUNTU_CODE),$(UBUNTU_CODE)-updates \
	    -a amd64 \
	    -c main,restricted,universe,multiverse \
	    --no-rdepends
