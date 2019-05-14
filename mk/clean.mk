clean-chroot clean-live clean-pool: clean-%:
	# Unmount chroot if mounted
	scripts/unmount.sh "$(BUILD)/$*.partial" || true

	# Remove chroot
	sudo rm -rf "$(BUILD)/$*" "$(BUILD)/$*.partial"

clean: clean-chroot clean-live clean-pool
	# Remove partial debootstrap
	sudo rm -rf "$(BUILD)/debootstrap.partial"

	# Remove grub
	sudo rm -rf "$(BUILD)/grub" "$(BUILD)/grub.partial"

	# Remove ISO extract
	sudo rm -rf "$(BUILD)/iso"

	# Remove germinate
	rm -rf "$(BUILD)/germinate"

	# Remove tag files, partial files
	rm -f $(BUILD)/*.tag $(BUILD)/*.partial

	# Remove QEMU files
	rm -f $(BUILD)/*.img $(BUILD)/OVMF_VARS.fd

	# Remove build artifacts
	rm -f $(BUILD)/*.tar $(BUILD)/*.iso $(BUILD)/*.zsync $(BUILD)/SHA256SUMS $(BUILD)/SHA256SUMS.gpg

distclean:
	# Remove debootstrap
	sudo rm -rf "$(BUILD)/debootstrap"

	# Execute normal clean
	make clean
