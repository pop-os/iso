clean-chroot clean-squashfs clean-pool: clean-%:
	# Unmount chroot if mounted
	scripts/unmount.sh "$(BUILD)/$*.partial" || true

	# Remove chroot
	sudo rm -rf "$(BUILD)/$*" "$(BUILD)/$*.partial"

clean: clean-chroot clean-squashfs clean-pool
	# Remove partial debootstrap
	sudo rm -rf "$(BUILD)/debootstrap.partial"

	# Remove casper
	sudo rm -rf "$(BUILD)/casper" "$(BUILD)/casper.partial"

	# Remove grub
	sudo rm -rf "$(BUILD)/grub" "$(BUILD)/grub.partial"

	# Remove ISO extract
	sudo rm -rf "$(BUILD)/iso"

	# Remove tag files, partial files, and build artifacts
	rm -f $(BUILD)/*.tag $(BUILD)/*.partial $(BUILD)/$(DISTRO_CODE).tar $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/$(DISTRO_CODE).iso.zsync $(BUILD)/SHA256SUMS $(BUILD)/SHA256SUMS.gpg

	# Remove QEMU files
	rm -f $(BUILD)/*.img $(BUILD)/OVMF_VARS.fd

distclean:
	# Remove debootstrap
	sudo rm -rf "$(BUILD)/debootstrap"

	# Execute normal clean
	make clean
