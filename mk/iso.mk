$(BUILD)/iso_create.tag:
	# Remove old ISO
	sudo rm -rf "$(BUILD)/iso"

	# Create new ISO
	mkdir -p "$(BUILD)/iso"

	touch "$@"

$(BUILD)/iso_casper.tag: $(BUILD)/squashfs $(BUILD)/chroot.tag $(BUILD)/squashfs.tag $(BUILD)/iso_create.tag
	# Remove old casper directory
	sudo rm -rf "$(BUILD)/iso/casper"

	# Create new casper directory
	mkdir -p "$(BUILD)/iso/casper"

	# Copy vmlinuz
	sudo cp "$(BUILD)/squashfs/vmlinuz" "$(BUILD)/iso/casper/vmlinuz.efi"

	# Copy initrd
	sudo cp "$(BUILD)/squashfs/initrd.img" "$(BUILD)/iso/casper/initrd.gz"

	# Update manifest
	cp "$(BUILD)/squashfs.tag" "$(BUILD)/iso/casper/filesystem.manifest"
	grep -F -x -v -f "$(BUILD)/chroot.tag" "$(BUILD)/squashfs.tag" | cut -f1 > "$(BUILD)/iso/casper/filesystem.manifest-remove"

	# Update filesystem size
	sudo du -sx --block-size=1 "$(BUILD)/squashfs" | cut -f1 > "$(BUILD)/iso/casper/filesystem.size"

	# Rebuild filesystem image
	sudo mksquashfs "$(BUILD)/squashfs" "$(BUILD)/iso/casper/filesystem.squashfs" -noappend -fstime "$(DISTRO_EPOCH)"

	sudo chown -R "$(USER):$(USER)" "$(BUILD)/iso/casper"

	touch "$@"

$(BUILD)/iso_pool.tag: $(BUILD)/pool $(BUILD)/iso_create.tag
	# Remove dists and pool directory
	sudo rm -rf "$(BUILD)/iso/dists" "$(BUILD)/iso/pool"

	# Copy package pool
	sudo cp -r "$</pool" "$(BUILD)/iso/pool"
	sudo chown -R "$(USER):$(USER)" "$(BUILD)/iso/pool"

	# Update pool package lists
	cd "$(BUILD)/iso" && \
	for pool in $$(ls -1 pool); do \
		mkdir -p "dists/$(UBUNTU_CODE)/$$pool/binary-amd64" && \
		apt-ftparchive packages "pool/$$pool" | gzip > "dists/$(UBUNTU_CODE)/$$pool/binary-amd64/Packages.gz" && \
		sed "s|COMPONENT|$$pool|g; $(SED)" "../../../data/Release" > "dists/$(UBUNTU_CODE)/$$pool/binary-amd64/Release"; \
	done; \
	apt-ftparchive release "dists/$(UBUNTU_CODE)" > "dists/$(UBUNTU_CODE)/Release"

	touch "$@"

$(BUILD)/iso_data.tag: $(BUILD)/iso_create.tag
	git submodule update --init data/default-settings

	sed "$(SED)" "data/README.diskdefines" > "$(BUILD)/iso/README.diskdefines"

	# Replace disk info
	rm -rf "$(BUILD)/iso/.disk"
	mkdir -p "$(BUILD)/iso/.disk"
	sed "$(SED)" "data/disk/base_installable" > "$(BUILD)/iso/.disk/base_installable"
	sed "$(SED)" "data/disk/casper-uuid-generic" > "$(BUILD)/iso/.disk/casper-uuid-generic"
	sed "$(SED)" "data/disk/cd_type" > "$(BUILD)/iso/.disk/cd_type"
	sed "$(SED)" "data/disk/info" > "$(BUILD)/iso/.disk/info"
	sed "$(SED)" "data/disk/release_notes_url" > "$(BUILD)/iso/.disk/release_notes_url"

	# Replace preseeds
	rm -rf "$(BUILD)/iso/preseed"
	mkdir -p "$(BUILD)/iso/preseed"
	sed "$(SED)" "data/preseed.seed" > "$(BUILD)/iso/preseed/$(DISTRO_CODE).seed"

	# Update grub config
	rm -rf "$(BUILD)/iso/boot/grub"
	mkdir -p "$(BUILD)/iso/boot/grub"
	sed "$(SED)" "data/grub/grub.cfg" > "$(BUILD)/iso/boot/grub/grub.cfg"
	sed "$(SED)" "data/grub/loopback.cfg" > "$(BUILD)/iso/boot/grub/loopback.cfg"

	# Copy grub theme
	cp -r "data/default-settings/usr/share/grub/themes" "$(BUILD)/iso/boot/grub/themes"

	touch "$@"

$(BUILD)/iso_sum.tag: $(BUILD)/iso_casper.tag $(BUILD)/iso_pool.tag $(BUILD)/iso_data.tag
	# Calculate md5sum
	cd "$(BUILD)/iso" && \
	rm -f md5sum.txt && \
	find -type f -print0 | sort -z | xargs -0 md5sum > md5sum.txt

	touch "$@"

$(BUILD)/$(DISTRO_CODE).tar: $(BUILD)/iso_sum.tag
	tar --create \
		--mtime="@$(DISTRO_EPOCH)" --sort=name \
	    --owner=0 --group=0 --numeric-owner --mode='a=,u+rX' \
	    --file "$@.partial" --directory "$(BUILD)/iso" .

	mv "$@.partial" "$@"

$(BUILD)/$(DISTRO_CODE).iso: $(BUILD)/iso_sum.tag
	grub-mkrescue -o "$@.partial" "$(BUILD)/iso" -- \
		-volid "$(DISTRO_NAME) $(DISTRO_VERSION) amd64"


	mv "$@.partial" "$@"
