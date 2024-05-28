$(BUILD)/debootstrap:
	mkdir -p $(BUILD)

	# Remove old debootstrap
	sudo rm -rf "$@" "$@.partial"

	# Install using debootstrap
	if ! sudo debootstrap \
		--arch=$(DISTRO_ARCH) \
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
	sudo cp "scripts/repos.sh" "$@.partial/iso/repos.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Install dependencies of chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
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

	# Setup DEB822 format repos on 20.10 or later
	if [ -n "${DEB822}" ]; then \
		sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
			"FILENAME=\"/etc/apt/sources.list.d/system.sources\" \
			NAME=\"${DISTRO_NAME} System Sources\" \
			TYPES=\"deb deb-src\" \
			URIS=\"${UBUNTU_MIRROR}\" \
			SUITES=\"$(UBUNTU_CODE) $(UBUNTU_CODE)-security $(UBUNTU_CODE)-updates $(UBUNTU_CODE)-backports\" \
			COMPONENTS=\"main restricted universe multiverse\" \
			/iso/repos.sh"; \
	fi

	# Add release URIs
	if [ -n "${RELEASE_URI}" ]; then \
		sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
			"FILENAME=\"/etc/apt/sources.list.d/${DISTRO_CODE}-release.sources\" \
			NAME=\"${DISTRO_NAME} Release Sources\" \
			TYPES=\"deb deb-src\" \
			URIS=\"${RELEASE_URI}\" \
			SUITES=\"${UBUNTU_CODE}\" \
			COMPONENTS=\"main\" \
			/iso/repos.sh"; \
	fi

	# Run chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"KEY=\"/iso/pop.key\" \
		STAGING_BRANCHES=\"$(STAGING_BRANCHES)\" \
		UPDATE=1 \
		UPGRADE=1 \
		INSTALL=\"$(DISTRO_PKGS)\" \
		LANGUAGES=\"$(LANGUAGES)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh \
		$(DISTRO_REPOS)"

	# Add extra URIS
	if [ -n "${APPS_URI}" ]; then \
		sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
			"FILENAME=\"/etc/apt/sources.list.d/${DISTRO_CODE}-apps.sources\" \
			NAME=\"${DISTRO_NAME} Applications\" \
			TYPES=\"deb\" \
			URIS=\"${APPS_URI}\" \
			SUITES=\"${UBUNTU_CODE}\" \
			COMPONENTS=\"main\" \
			/iso/repos.sh"; \
	fi

	# Rerun chroot script to install POST_DISTRO_PKGS
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"INSTALL=\"$(POST_DISTRO_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

ifeq ($(DISTRO_MACHINE),x13s)
	# Add specific kernel and initramfs configuration for x13s, also some 
	# setup scripts for newest sc8280xp device-specific firmwares from the 
	# Windows partition, newest WLAN firmware, bootmac support for consistent 
	# MACs on WLAN and BT.

	# /media/jglathe/rootfs68n/ has Ubuntu_Desktop_24.04_x13s_6.8.8.img mounted 
	# /media/jglathe/rootfs69p/ has pop-os_22.04_x13s.img mounted 
	# with all the scriptery we need
	sudo mkdir -p "$@.partial/packages"
	sudo cp /home/jglathe/src/kernel/6.9.1-for-pop-os24.04/*.deb $@.partial/packages/
	sudo mkdir -p "$@.partial/etc/initramfs-tools/"
	sudo cp /media/jglathe/rootfs68n/etc/initramfs-tools/modules $@.partial/etc/initramfs-tools/ 
	sudo mkdir -p "$@.partial/etc/initramfs-tools/hooks"
	sudo cp /media/jglathe/rootfs68n/etc/initramfs-tools/hooks/x13s-firmware $@.partial/etc/initramfs-tools/hooks/
	sudo chmod -x $@.partial/etc/initramfs-tools/hooks/x13s-firmware
	sudo cp /media/jglathe/rootfs68n/etc/default/grub $@.partial/etc/default/
	sudo cp /media/jglathe/rootfs68n/usr/lib/systemd/system/copy_firmware.service $@.partial/usr/lib/systemd/system/
	sudo cp /media/jglathe/rootfs68n/usr/local/bin/fetch_sc8280xp_fw.sh $@.partial/usr/local/bin/
	sudo cp /media/jglathe/rootfs68n/usr/local/bin/temperatures.sh $@.partial/usr/local/bin/
	sudo cp /media/jglathe/rootfs68n/usr/bin/bootmac $@.partial/usr/bin/
	sudo cp /media/jglathe/rootfs69p/var/spool/cron/crontabs/root $@.partial/var/spool/cron/crontabs/
	sudo mkdir -p "$@.partial/usr/lib/firmware/updates"
	sudo cp -R /media/jglathe/rootfs69p/usr/lib/firmware/updates/* $@.partial//usr/lib/firmware/updates/

	# add db entry and machine identifier in flash-kernel for the x13s
	sudo mkdir -p "$@.partial/etc/flash-kernel"
	sudo cp /media/jglathe/rootfs69p/etc/flash-kernel/db $@.partial/etc/flash-kernel/
	sudo cp /media/jglathe/rootfs69p/etc/flash-kernel/machine $@.partial/etc/flash-kernel/
	# install our custom kernel
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"OWN_KERNEL=1 \
		/iso/chroot.sh"
endif

	# Remove apt preferences
	sudo rm "$@.partial/etc/apt/preferences.d/pop-iso"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	sudo rm -rf "$@.partial"/root/.launchpadlib

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/chroot.tag: $(BUILD)/chroot
	sudo $(CHROOT) "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"

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

	# Copy ubuntu-drivers-common default prime-discrete configuration
	sudo cp "data/prime-discrete" "$@.partial/etc/prime-discrete"

	# Run chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"KEY=\"/iso/apt-cdrom.key\" \
		STAGING_BRANCHES=\"$(STAGING_BRANCHES)\" \
		INSTALL=\"$(LIVE_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Remove undesired casper script
	if [ -e "$@.partial/usr/share/initramfs-tools/scripts/casper-bottom/01integrity_check" ]; then \
		sudo rm -f "$@.partial/usr/share/initramfs-tools/scripts/casper-bottom/01integrity_check"; \
	fi

	# Make casper script for initial setup set the version
	if [ -n "$(GNOME_INITIAL_SETUP_STAMP)" ]; then \
		sudo sed -i \
		's|touch /root/home/$$USERNAME/.config/gnome-initial-setup-done|echo -n "$(GNOME_INITIAL_SETUP_STAMP)" > /root/home/$$USERNAME/.config/gnome-initial-setup-done|' \
		"$@.partial/usr/share/initramfs-tools/scripts/casper-bottom/52gnome_initial_setup"; \
	fi

	# Update apt cache
	sudo $(CHROOT) "$@.partial" /usr/bin/apt-get update

	# Update appstream cache
	if [ -e "$@.partial/usr/bin/appstreamcli" ]; then \
		sudo $(CHROOT) "$@.partial" /usr/bin/appstreamcli refresh-cache --force; \
	fi

	# Update fwupd cache
	if [ -e "$@.partial/usr/bin/fwupdtool" ]; then \
		sudo $(CHROOT) "$@.partial" /usr/bin/fwupdtool refresh --force; \
	fi

	# Run console-setup script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"/iso/console-setup.sh"

	# Create missing network-manager file
	if [ -e "$@.partial/etc/NetworkManager/conf.d" ]; then \
		sudo touch "$@.partial/etc/NetworkManager/conf.d/10-globally-managed-devices.conf"; \
	fi

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	sudo rm -rf "$@.partial"/root/.launchpadlib

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/live.tag: $(BUILD)/live
	sudo $(CHROOT) "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"

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

	# Create pool directory
	sudo mkdir -p "$@.partial/iso/pool"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$@.partial/iso/chroot.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Run chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"MAIN_POOL=\"$(MAIN_POOL)\" \
		RESTRICTED_POOL=\"$(RESTRICTED_POOL)\" \
		INSTALL=\"$(POOL_PKGS)\" \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

ifeq ($(DISTRO_MACHINE),x13s)
	# enable the x13s-firmware script
	sudo chmod +x "$@.partial"/etc/initramfs-tools/hooks/x13s-firmware
endif

	sudo rm -rf "$@.partial"/root/.launchpadlib

	# Save package pool
	sudo mv "$@.partial/iso/pool" "$@.partial/pool"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"
