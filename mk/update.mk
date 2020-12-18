update-chroot update-live: update-%: $(BUILD)/%
	# Unmount chroot if mounted
	scripts/unmount.sh "$<.partial"

	# Remove old chroot
	sudo rm -rf "$<.partial"

	# Move chroot
	sudo mv "$<" "$<.partial"

	# Make temp directory for modifications
	sudo rm -rf "$<.partial/iso"
	sudo mkdir -p "$<.partial/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$<.partial/iso/chroot.sh"

	# Mount chroot
	"scripts/mount.sh" "$<.partial"

	# Run chroot script
	sudo $(CHROOT) "$<.partial" /bin/bash -e -c \
		"UPDATE=1 \
		UPGRADE=1 \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$<.partial"

	# Remove temp directory for modifications
	sudo rm -rf "$<.partial/iso"

	sudo touch "$<.partial"
	sudo mv "$<.partial" "$<"
