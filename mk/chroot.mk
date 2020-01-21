$(BUILD)/debootstrap:
	mkdir -p $(BUILD)

	# Remove old debootstrap
	sudo rm -rf "$@" "$@.partial"

	# Install using debootstrap
	if ! sudo debootstrap \
		--arch=amd64 \
		"$(UBUNTU_CODE)" \
		"$@.partial" \
		"$(UBUNTU_MIRROR)"; \
	then \
		cat "$@.partial/debootstrap/debootstrap.log"; \
		false; \
	fi

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/chroot: $(BUILD)/debootstrap
	# Unmount chroot if mounted
	scripts/unmount.sh "$@.partial"

	# Remove old chroot
	sudo rm -rf "$@" "$@.partial"

	# Copy chroot
	sudo cp -a "$<" "$@.partial"

	# Make temp directory for modifications
	sudo rm -rf "$@.partial/iso"
	sudo mkdir -p "$@.partial/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$@.partial/iso/chroot.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Install dependencies of chroot script
	sudo chroot "$@.partial" /bin/bash -e -c \
		"UPDATE=1 \
		UPGRADE=1 \
		INSTALL=\"--no-install-recommends gnupg software-properties-common\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Copy GPG public key for Pop staging repositories
	gpg --batch --yes --export --armor "204DD8AEC33A7AFF" | sudo tee "$@.partial/iso/pop.key"

	# Clean APT sources
	sudo truncate --size=0 "$@.partial/etc/apt/sources.list"

	# Temporarily set apt preferences
	sudo cp "data/apt-preferences" "$@.partial/etc/apt/preferences.d/pop-iso"

	# Copy kernelstub configuration
	sudo mkdir "$@.partial/etc/kernelstub"
	sudo cp "data/kernelstub" "$@.partial/etc/kernelstub/configuration"

	# Run chroot script
	sudo chroot "$@.partial" /bin/bash -e -c \
		"KEY=\"/iso/pop.key\" \
		UPDATE=1 \
		UPGRADE=1 \
		INSTALL=\"$(DISTRO_PKGS)\" \
		LANGUAGES=\"$(LANGUAGES)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh \
		$(DISTRO_REPOS)"

	# Rerun chroot script to install POST_DISTRO_PKGS
	sudo chroot "$@.partial" /bin/bash -e -c \
		"INSTALL=\"$(POST_DISTRO_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Remove apt preferences
	sudo rm "$@.partial/etc/apt/preferences.d/pop-iso"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/chroot.tag: $(BUILD)/chroot
	sudo chroot "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"

$(BUILD)/live: $(BUILD)/chroot
	# Unmount chroot if mounted
	scripts/unmount.sh "$@.partial"

	# Remove old chroot
	sudo rm -rf "$@" "$@.partial"

	# Copy chroot
	sudo cp -a "$<" "$@.partial"

	# Make temp directory for modifications
	sudo rm -rf "$@.partial/iso"
	sudo mkdir -p "$@.partial/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$@.partial/iso/chroot.sh"

	# Copy console-setup script
	sudo cp "scripts/console-setup.sh" "$@.partial/iso/console-setup.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Copy GPG public key for APT CDROM
	gpg --batch --yes --export --armor "$(GPG_NAME)" | sudo tee "$@.partial/iso/apt-cdrom.key"

	# Copy system76-power default modprobe.d configuration
	sudo cp "data/system76-power.conf" "$@.partial/etc/modprobe.d/system76-power.conf"

	# Run chroot script
	sudo chroot "$@.partial" /bin/bash -e -c \
		"KEY=\"/iso/apt-cdrom.key\" \
		INSTALL=\"$(LIVE_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Update apt cache
	sudo chroot "$@.partial" /usr/bin/apt-get update

	# Update appstream cache
	sudo chroot "$@.partial" /usr/bin/appstreamcli refresh-cache --force

	# Run console-setup script
	sudo chroot "$@.partial" /bin/bash -e -c \
		"/iso/console-setup.sh"

	# Create missing network-manager file
	sudo touch "$@.partial/etc/NetworkManager/conf.d/10-globally-managed-devices.conf"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/live.tag: $(BUILD)/live
	sudo chroot "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"

$(BUILD)/pool: $(BUILD)/chroot
	# Unmount chroot if mounted
	scripts/unmount.sh "$@.partial"

	# Remove old chroot
	sudo rm -rf "$@" "$@.partial"

	# Copy chroot
	sudo cp -a "$<" "$@.partial"

	# Make temp directory for modifications
	sudo rm -rf "$@.partial/iso"
	sudo mkdir -p "$@.partial/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$@.partial/iso/chroot.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Run chroot script
	sudo chroot "$@.partial" /bin/bash -e -c \
		"MAIN_POOL=\"$(MAIN_POOL)\" \
		RESTRICTED_POOL=\"$(RESTRICTED_POOL)\" \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	# Save package pool
	sudo mv "$@.partial/iso/pool" "$@.partial/pool"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"
