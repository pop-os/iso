clean:
	# Unmount chroot if mounted
	scripts/unmount.sh "$(BUILD)/chroot.partial" || true

	# Unmount squashfs if mounted
	scripts/unmount.sh "$(BUILD)/squashfs.partial" || true

	# Unmount pool if mounted
	scripts/unmount.sh "$(BUILD)/pool.partial" || true

	# Remove chroot
	sudo rm -rf "$(BUILD)/chroot" "$(BUILD)/chroot.partial"

	# Remove squashfs
	sudo rm -rf "$(BUILD)/squashfs" "$(BUILD)/squashfs.partial"

	# Remove pool
	sudo rm -rf "$(BUILD)/pool" "$(BUILD)/pool.partial"

	# Remove casper
	sudo rm -rf "$(BUILD)/casper" "$(BUILD)/casper.partial"

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
