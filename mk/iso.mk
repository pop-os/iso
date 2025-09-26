$(BUILD)/iso_create.tag:
	# Remove old ISO
	sudo rm -rf "$(BUILD)/iso"

	# Create new ISO
	mkdir -p "$(BUILD)/iso"

	touch "$@"

$(BUILD)/iso_casper.tag: $(BUILD)/live $(BUILD)/chroot.tag $(BUILD)/live.tag $(BUILD)/iso_create.tag
	# Remove old casper directory
	sudo rm -rf "$(BUILD)/iso/casper"*

	# Create new casper directory
	mkdir -p "$(BUILD)/iso/$(CASPER_PATH)"

	# Copy vmlinuz
	if [ -e "$(BUILD)/live/boot/vmlinuz" ]; then \
		sudo cp "$(BUILD)/live/boot/vmlinuz" "$(BUILD)/iso/$(CASPER_PATH)/vmlinuz.efi"; \
	else \
		sudo cp "$(BUILD)/live/vmlinuz" "$(BUILD)/iso/$(CASPER_PATH)/vmlinuz.efi"; \
	fi

	# Copy initrd
	if [ -e "$(BUILD)/live/boot/initrd.img" ]; then \
		sudo cp "$(BUILD)/live/boot/initrd.img" "$(BUILD)/iso/$(CASPER_PATH)/initrd.gz"; \
	else \
		sudo cp "$(BUILD)/live/initrd.img" "$(BUILD)/iso/$(CASPER_PATH)/initrd.gz"; \
	fi

	# Update manifest
	cp "$(BUILD)/live.tag" "$(BUILD)/iso/$(CASPER_PATH)/filesystem.manifest"
	grep -F -x -v -f "$(BUILD)/chroot.tag" "$(BUILD)/live.tag" | cut -f1 > "$(BUILD)/iso/$(CASPER_PATH)/filesystem.manifest-remove"

	# Update filesystem size
	sudo du -sx --block-size=1 "$(BUILD)/live" | cut -f1 > "$(BUILD)/iso/$(CASPER_PATH)/filesystem.size"

	# Rebuild filesystem image
	sudo mksquashfs "$(BUILD)/live" \
		"$(BUILD)/iso/$(CASPER_PATH)/filesystem.squashfs" \
		-noappend -fstime "$(DISTRO_EPOCH)" \
		-comp xz -b 1M -Xdict-size 1M -Xbcj x86

	sudo chown -R "$(USER):$(USER)" "$(BUILD)/iso/$(CASPER_PATH)"

	ln -sf "$(CASPER_PATH)" "$(BUILD)/iso/casper"

	touch "$@"

$(BUILD)/iso_pool.tag: $(BUILD)/pool $(BUILD)/iso_create.tag
	# Remove dists and pool directory
	sudo rm -rf "$(BUILD)/iso/dists" "$(BUILD)/iso/pool"

	# Copy package pool
	sudo cp -r "$</pool" "$(BUILD)/iso/pool"
	sudo chown -R "$(USER):$(USER)" "$(BUILD)/iso/pool"

	# Fix pool paths
	./scripts/pool.sh "$(BUILD)/iso/pool/"*

	# Update pool package lists
	cd "$(BUILD)/iso" && \
	mkdir -p "dists/$(UBUNTU_CODE)" && \
	for pool in $$(ls -1 pool); do \
		mkdir -p "dists/$(UBUNTU_CODE)/$$pool/binary-$(DISTRO_ARCH)" && \
		apt-ftparchive packages "pool/$$pool" > "dists/$(UBUNTU_CODE)/$$pool/binary-$(DISTRO_ARCH)/Packages" && \
		gzip -k "dists/$(UBUNTU_CODE)/$$pool/binary-$(DISTRO_ARCH)/Packages" && \
		sed "s|COMPONENT|$$pool|g; $(SED)" "../../../../data/Release" > "dists/$(UBUNTU_CODE)/$$pool/binary-$(DISTRO_ARCH)/Release"; \
	done; \
	apt-ftparchive \
		-o "APT::FTPArchive::Release::Acquire-By-Hash=yes" \
		-o "APT::FTPArchive::Release::Architectures=$(DISTRO_ARCH)" \
		-o "APT::FTPArchive::Release::Codename=$(UBUNTU_CODE)" \
		-o "APT::FTPArchive::Release::Components=$$(ls -1 pool | tr $$'\n' ' ')" \
		-o "APT::FTPArchive::Release::Description=$(DISTRO_CODE) $(DISTRO_VERSION)" \
		-o "APT::FTPArchive::Release::Label=Ubuntu" \
		-o "APT::FTPArchive::Release::Origin=Ubuntu" \
		-o "APT::FTPArchive::Release::Suite=$(UBUNTU_CODE)" \
		-o "APT::FTPArchive::Release::Version=$(DISTRO_VERSION)" \
		release "dists/$(UBUNTU_CODE)" \
		> "dists/$(UBUNTU_CODE)/Release" && \
	gpg --batch --yes --digest-algo sha512 --sign --detach-sign --armor --local-user "$(GPG_NAME)" -o "dists/$(UBUNTU_CODE)/Release.gpg" "dists/$(UBUNTU_CODE)/Release" && \
	cd "dists" && \
	ln -s "$(UBUNTU_CODE)" stable && \
	ln -s "$(UBUNTU_CODE)" unstable

	touch "$@"

$(BUILD)/grub: $(BUILD)/pool
	rm -rf "$@.partial"
	mkdir "$@.partial"

	rm -rf "$(BUILD)/iso/efi"
	mkdir -p "$(BUILD)/iso/efi/boot/"

ifeq ($(DISTRO_ARCH),amd64)

	grub-mkimage \
		--directory /usr/lib/grub/i386-pc \
		--prefix /boot/grub \
		--output "$@.partial/eltorito.img" \
		--format i386-pc-eltorito \
		--compression auto \
		--config data/grub/load.cfg \
		biosdisk iso9660

	cp -r "data/efi/shimx64.efi.signed" "$(BUILD)/iso/efi/boot/bootx64.efi"
	cp -r "/usr/lib/grub/x86_64-efi-signed/gcdx64.efi.signed" "$(BUILD)/iso/efi/boot/grubx64.efi"

else ifeq ($(DISTRO_ARCH),arm64)

	cp -v "$(BUILD)/pool/usr/lib/shim/shimaa64.efi.signed.latest" "$(BUILD)/iso/efi/boot/bootaa64.efi"
	cp -v "$(BUILD)/pool/usr/lib/grub/arm64-efi-signed/gcdaa64.efi.signed" "$(BUILD)/iso/efi/boot/grubaa64.efi"

endif

	mkfs.vfat -C "$@.partial/efi.img" 4096
	mcopy -s -i "$@.partial/efi.img" "$(BUILD)/iso/efi" ::/

	touch "$@.partial"
	mv "$@.partial" "$@"

$(BUILD)/iso_data.tag: $(BUILD)/iso_create.tag $(BUILD)/grub $(BUILD)/pool
	git submodule update --init data/grub-theme

	# Replace disk info
	rm -rf "$(BUILD)/iso/.disk"
	mkdir -p "$(BUILD)/iso/.disk"
	sed "$(SED)" "data/disk/info" > "$(BUILD)/iso/.disk/info"

	# Update grub config
	rm -rf "$(BUILD)/iso/boot/grub"
	mkdir -p "$(BUILD)/iso/boot/grub"
	sed "$(SED)" "data/grub/grub.cfg" > "$(BUILD)/iso/boot/grub/grub.cfg"
	cp /usr/share/grub/unicode.pf2 "$(BUILD)/iso/boot/grub/font.pf2"

	# Copy grub theme
	cp -r "data/grub-theme/usr/share/grub/themes" "$(BUILD)/iso/boot/grub/themes"

ifeq ($(DISTRO_ARCH),amd64)

	# Copy grub modules (BIOS)
	mkdir -p "$(BUILD)/iso/boot/grub/i386-pc"
	cp "$(BUILD)/grub/eltorito.img" "/usr/lib/grub/i386-pc/"*.mod "$(BUILD)/iso/boot/grub/i386-pc/"

	# Copy grub modules (EFI)
	cp "$(BUILD)/grub/efi.img" "$(BUILD)/iso/boot/grub"
	mkdir -p "$(BUILD)/iso/boot/grub/x86_64-efi"
	cp "/usr/lib/grub/x86_64-efi/"*.mod "$(BUILD)/iso/boot/grub/x86_64-efi/"

	# Copy isolinux files
	rm -rf "$(BUILD)/iso/isolinux"
	mkdir -p "$(BUILD)/iso/isolinux"
	cp /usr/lib/ISOLINUX/isolinux.bin "$(BUILD)/iso/isolinux/isolinux.bin"
	cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$(BUILD)/iso/isolinux/ldlinux.c32"
	sed "$(SED)" "data/isolinux/isolinux.cfg" > "$(BUILD)/iso/isolinux/isolinux.cfg"

else ifeq ($(DISTRO_ARCH),arm64)

	# Copy grub modules (EFI)
	cp "$(BUILD)/grub/efi.img" "$(BUILD)/iso/boot/grub"
	mkdir -p "$(BUILD)/iso/boot/grub/arm64-efi"
	cp "$(BUILD)/pool/usr/lib/grub/arm64-efi/"*.mod "$(BUILD)/iso/boot/grub/arm64-efi/"

	# Copy devicetree files
	rm -rf "$(BUILD)/iso/dtb"
	cp -r "$(BUILD)/chroot/usr/lib/firmware/"*"/device-tree" "$(BUILD)/iso/dtb"

endif

	touch "$@"

$(BUILD)/iso_sum.tag: $(BUILD)/iso_casper.tag $(BUILD)/iso_pool.tag $(BUILD)/iso_data.tag
	# Calculate md5sum
	cd "$(BUILD)/iso" && \
	rm -f md5sum.txt && \
	find -type f -print0 | sort -z | xargs -0 md5sum > md5sum.txt

	touch "$@"

$(TAR): $(BUILD)/iso_sum.tag
	tar --create \
		--mtime="@$(DISTRO_EPOCH)" --sort=name \
	    --owner=0 --group=0 --numeric-owner --mode='a=,u+rX' \
	    --file "$@.partial" --directory "$(BUILD)/iso" .

	mv "$@.partial" "$@"

$(ISO): $(BUILD)/iso_sum.tag
ifeq ($(DISTRO_ARCH),amd64)
	xorriso -as mkisofs \
		-J \
		-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
		-c isolinux/boot.cat -b isolinux/isolinux.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		-eltorito-alt-boot -e boot/grub/efi.img \
		-no-emul-boot -isohybrid-gpt-basdat \
		-r -V "$(DISTRO_VOLUME_LABEL)" \
		-o "$@.partial" "$(BUILD)/iso" -- \
		-volume_date all_file_dates ="$(DISTRO_EPOCH)"
else
	xorriso -as mkisofs \
		-J \
		-eltorito-alt-boot -e boot/grub/efi.img \
		-no-emul-boot -isohybrid-gpt-basdat \
		-r -V "$(DISTRO_VOLUME_LABEL)" \
		-o "$@.partial" "$(BUILD)/iso" -- \
		-volume_date all_file_dates ="$(DISTRO_EPOCH)"
endif

	mv "$@.partial" "$@"

$(ISO).zsync: $(ISO)
	cd "$(BUILD)" && zsyncmake -o "`basename "$@.partial"`" "`basename "$<"`"

	mv "$@.partial" "$@"

$(BUILD)/SHA256SUMS: $(ISO)
	cd "$(BUILD)" && sha256sum -b "`basename "$<"`" > "`basename "$@.partial"`"

	mv "$@.partial" "$@"

$(BUILD)/SHA256SUMS.gpg: $(BUILD)/SHA256SUMS
	cd "$(BUILD)" && gpg --batch --yes --output "`basename "$@.partial"`" --detach-sig "`basename "$<"`"

	mv "$@.partial" "$@"
