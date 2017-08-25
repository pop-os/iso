DISTRO_VERSION?=17.10

DISTRO_EPOCH?=$(shell date +%s)

DISTRO_DATE?=$(shell date +%Y%M%d)

DISTRO_NAME=Pop_OS

DISTRO_CODE=pop-os

DISTRO_REPOS=\
	main \
	universe \
	restricted \
	multiverse \
	ppa:system76/pop

DISTRO_PKGS=\
	ubuntu-minimal \
	ubuntu-standard \
	pop-desktop

LIVE_PKGS=\
	casper \
	jfsutils \
	linux-generic \
	linux-signed-generic \
	lupin-casper \
	mokutil \
	mtools \
	reiserfsprogs \
	ubiquity-frontend-gtk \
	ubiquity-slideshow-pop \
	xfsprogs \
	fcitx \
	fcitx-hangul \
	fcitx-module-cloudpinyin \
	fcitx-mozc \
	fcitx-pinyin \
	fcitx-table \
	fcitx-unikey \
	fcitx-ui-qimpanel \
	firefox-locale-de \
	firefox-locale-en \
	firefox-locale-es \
	firefox-locale-fr \
	firefox-locale-it \
	firefox-locale-pt \
	firefox-locale-ru \
	firefox-locale-zh-hans \
	fonts-arphic-ukai \
	fonts-arphic-uming \
	fonts-dejavu-core \
	fonts-droid-fallback \
	fonts-freefont-ttf \
	fonts-guru \
	fonts-guru-extra \
	fonts-kacst \
	fonts-kacst-one \
	fonts-khmeros-core \
	fonts-lao \
	fonts-liberation \
	fonts-lklug-sinhala \
	fonts-lohit-guru \
	fonts-nanum \
	fonts-noto-cjk \
	fonts-noto-mono \
	fonts-opensymbol \
	fonts-sil-abyssinica \
	fonts-sil-padauk \
	fonts-symbola \
	fonts-takao-pgothic \
	fonts-thai-tlwg \
	fonts-tibetan-machine \
	fonts-tlwg-garuda \
	fonts-tlwg-garuda-ttf \
	fonts-tlwg-kinnari \
	fonts-tlwg-kinnari-ttf \
	fonts-tlwg-laksaman \
	fonts-tlwg-laksaman-ttf \
	fonts-tlwg-loma \
	fonts-tlwg-loma-ttf \
	fonts-tlwg-mono \
	fonts-tlwg-mono-ttf \
	fonts-tlwg-norasi \
	fonts-tlwg-norasi-ttf \
	fonts-tlwg-purisa \
	fonts-tlwg-purisa-ttf \
	fonts-tlwg-sawasdee \
	fonts-tlwg-sawasdee-ttf \
	fonts-tlwg-typewriter \
	fonts-tlwg-typewriter-ttf \
	fonts-tlwg-typist \
	fonts-tlwg-typist-ttf \
	fonts-tlwg-typo \
	fonts-tlwg-typo-ttf \
	fonts-tlwg-umpush \
	fonts-tlwg-umpush-ttf \
	fonts-tlwg-waree \
	fonts-tlwg-waree-ttf \
	gnome-getting-started-docs \
	gnome-getting-started-docs-de \
	gnome-getting-started-docs-es \
	gnome-getting-started-docs-fr \
	gnome-getting-started-docs-it \
	gnome-getting-started-docs-pt \
	gnome-getting-started-docs-ru \
	gnome-user-docs \
	gnome-user-docs-de \
	gnome-user-docs-es \
	gnome-user-docs-fr \
	gnome-user-docs-it \
	gnome-user-docs-pt \
	gnome-user-docs-ru \
	gnome-user-docs-zh-hans \
	hunspell-de-at-frami \
	hunspell-de-ch-frami \
	hunspell-de-de-frami \
	hunspell-en-au \
	hunspell-en-ca \
	hunspell-en-gb \
	hunspell-en-us \
	hunspell-en-za \
	hunspell-es \
	hunspell-fr \
	hunspell-fr-classical \
	hunspell-it \
	hunspell-pt-br \
	hunspell-pt-pt \
	hunspell-ru \
	hyphen-de \
	hyphen-en-ca \
	hyphen-en-gb \
	hyphen-en-us \
	hyphen-fr \
	hyphen-it \
	hyphen-pt-br \
	hyphen-pt-pt \
	hyphen-ru \
	ibus-gtk \
	ibus-gtk3 \
	language-pack-gnome-de \
	language-pack-gnome-en \
	language-pack-gnome-es \
	language-pack-gnome-fr \
	language-pack-gnome-it \
	language-pack-gnome-pt \
	language-pack-gnome-ru \
	language-pack-gnome-zh-hans \
	libreoffice-help-de \
	libreoffice-help-en-gb \
	libreoffice-help-en-us \
	libreoffice-help-es \
	libreoffice-help-fr \
	libreoffice-help-it \
	libreoffice-help-pt \
	libreoffice-help-pt-br \
	libreoffice-help-ru \
	libreoffice-help-zh-cn \
	libreoffice-help-zh-tw \
	libreoffice-l10n-de \
	libreoffice-l10n-en-gb \
	libreoffice-l10n-en-za \
	libreoffice-l10n-es \
	libreoffice-l10n-fr \
	libreoffice-l10n-it \
	libreoffice-l10n-pt \
	libreoffice-l10n-pt-br \
	libreoffice-l10n-ru \
	libreoffice-l10n-zh-cn \
	libreoffice-l10n-zh-tw \
	mozc-utils-gui \
	mythes-de \
	mythes-de-ch \
	mythes-en-au \
	mythes-en-us \
	mythes-fr \
	mythes-it \
	mythes-pt-pt \
	mythes-ru \
	onboard \
	wamerican \
	wbrazilian \
	wbritish \
	wfrench \
	witalian \
	wngerman \
	wogerman \
	wportuguese \
	wspanish \
	wswiss

RM_PKGS=\
	imagemagick-6.q16

MAIN_POOL=\
	b43-fwcutter \
	dkms \
	grub-efi \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	libuniconf4.6 \
	libwvstreams4.6-base \
	libwvstreams4.6-extras \
	lupin-support \
	mouseemu \
	oem-config \
	oem-config-gtk \
	oem-config-slideshow-ubuntu \
	setserial \
	shim \
	shim-signed \
	user-setup \
	wvdial

RESTRICTED_POOL=\
	bcmwl-kernel-source \
	intel-microcode \
	iucode-tool

ifeq ($(DISTRO_VERSION),17.04)
	UBUNTU_CODE=zesty
	UBUNTU_NAME=Zesty Zapus
	UBUNTU_ISO=http://cdimage.ubuntu.com/ubuntu-gnome/releases/17.04/release/ubuntu-gnome-17.04-desktop-amd64.iso
else ifeq ($(DISTRO_VERSION),17.10)
	UBUNTU_CODE=artful
	UBUNTU_NAME=Artful Aardvark
	UBUNTU_ISO=http://cdimage.ubuntu.com/ubuntu/daily-live/current/artful-desktop-amd64.iso
endif

BUILD=build/$(DISTRO_VERSION)

SED=\
	s|DISTRO_NAME|$(DISTRO_NAME)|g; \
	s|DISTRO_CODE|$(DISTRO_CODE)|g; \
	s|DISTRO_VERSION|$(DISTRO_VERSION)|g; \
	s|DISTRO_DATE|$(DISTRO_DATE)|g; \
	s|DISTRO_EPOCH|$(DISTRO_EPOCH)|g; \
	s|DISTRO_REPOS|$(DISTRO_REPOS)|g; \
	s|DISTRO_PKGS|$(DISTRO_PKGS)|g; \
	s|UBUNTU_CODE|$(UBUNTU_CODE)|g; \
	s|UBUNTU_NAME|$(UBUNTU_NAME)|g

XORRISO=$(shell command -v xorriso 2> /dev/null)
ZSYNC=$(shell command -v zsync 2> /dev/null)
SQUASHFS=$(shell command -v mksquashfs 2> /dev/null)

# Ensure that `zsync` is installed already
ifeq (,$(ZSYNC))
$(error zsync not found! Run deps.sh first.)
endif
# Ensure that `xorriso` is installed already
ifeq (,$(XORRISO))
$(error xorriso not found! Run deps.sh first.)
endif
# Ensure that `squashfs` is installed already
ifeq (,$(SQUASHFS))
$(error squashfs-tools not found! Run deps.sh first.)
endif

.PHONY: all clean distclean iso qemu qemu_uefi qemu_ubuntu qemu_ubuntu_uefi zsync

iso: $(BUILD)/$(DISTRO_CODE).iso

all: $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/$(DISTRO_CODE).iso.zsync $(BUILD)/SHA256SUMS $(BUILD)/SHA256SUMS.gpg

clean:
	# Unmount chroot if mounted
	scripts/unmount.sh "$(BUILD)/chroot.partial"

	# Unmount squashfs if mounted
	scripts/unmount.sh "$(BUILD)/squashfs.partial"

	# Unmount pool if mounted
	scripts/unmount.sh "$(BUILD)/pool.partial"

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

$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@.partial" 16G

	mv "$@.partial" "$@"

qemu: $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/qemu.img
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu.img \
		-boot d -cdrom "$<"

qemu_uefi: $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI" \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -cdrom "$<"

qemu_uefi_usb: $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI" \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -drive if=none,id=iso,file="$<" \
		-device nec-usb-xhci,id=xhci \
		-device usb-storage,bus=xhci.0,drive=iso

qemu_ubuntu: $(BUILD)/ubuntu.iso $(BUILD)/qemu.img
	qemu-system-x86_64 -name "Ubuntu $(DISTRO_VERSION) BIOS" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu.img \
		-boot d -cdrom "$<"

qemu_ubuntu_uefi: $(BUILD)/ubuntu.iso $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "Ubuntu $(DISTRO_VERSION) UEFI" \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -cdrom "$<"

$(BUILD)/ubuntu.iso:
	mkdir -p $(BUILD)

	# Download Ubuntu ISO
	wget -O "$@.partial" "$(UBUNTU_ISO)"

	mv "$@.partial" "$@"

zsync: $(BUILD)/ubuntu.iso
	zsync "$(UBUNTU_ISO).zsync" -o "$<"

$(BUILD)/debootstrap:
	mkdir -p $(BUILD)

	# Remove old debootstrap
	sudo rm -rf "$@" "$@.partial"

	# Install using debootstrap
	sudo debootstrap --arch=amd64 --include=software-properties-common "$(UBUNTU_CODE)" "$@.partial"

	mv "$@.partial" "$@"

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

	# Run chroot script
	sudo chroot "$@.partial" /bin/bash -e -c \
		"REPOS=\"$(DISTRO_REPOS)\" \
		UPDATE=1 \
		UPGRADE=1 \
		INSTALL=\"$(DISTRO_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo mv "$@.partial" "$@"

$(BUILD)/chroot.tag: $(BUILD)/chroot
	sudo chroot "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"

$(BUILD)/squashfs: $(BUILD)/chroot
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
		"INSTALL=\"$(LIVE_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	# Create missing network-manager file
	sudo touch "$@.partial/etc/NetworkManager/conf.d/10-globally-managed-devices.conf"

	# Patch ubiquity by removing plugins and updating order
	sudo sed -i "s/^AFTER = .*\$$/AFTER = 'language'/" "$@.partial/usr/lib/ubiquity/plugins/ubi-console-setup.py"
	sudo sed -i "s/^AFTER = .*\$$/AFTER = 'console_setup'/" "$@.partial/usr/lib/ubiquity/plugins/ubi-partman.py"
	sudo sed -i "s/^AFTER = .*\$$/AFTER = 'partman'/" "$@.partial/usr/lib/ubiquity/plugins/ubi-timezone.py"
	sudo rm -f "$@.partial/usr/lib/ubiquity/plugins/ubi-prepare.py"
	sudo rm -f "$@.partial/usr/lib/ubiquity/plugins/ubi-network.py"
	sudo rm -f "$@.partial/usr/lib/ubiquity/plugins/ubi-tasks.py"
	sudo rm -f "$@.partial/usr/lib/ubiquity/plugins/ubi-usersetup.py"
	sudo rm -f "$@.partial/usr/lib/ubiquity/plugins/ubi-wireless.py"

	# Remove gnome-classic
	sudo rm -f "$@.partial/usr/share/xsessions/gnome-classic.desktop"

	sudo mv "$@.partial" "$@"

$(BUILD)/squashfs.tag: $(BUILD)/squashfs
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

	sudo mv "$@.partial" "$@"

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
	sudo mksquashfs "$(BUILD)/squashfs" "$(BUILD)/iso/casper/filesystem.squashfs" -b 4096 -noappend -fstime "$(DISTRO_EPOCH)"

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

$(BUILD)/$(DISTRO_CODE).iso.zsync: $(BUILD)/$(DISTRO_CODE).iso
	cd "$(BUILD)" && zsyncmake -o "`basename "$@.partial"`" "`basename "$<"`"

	mv "$@.partial" "$@"

$(BUILD)/SHA256SUMS: $(BUILD)/$(DISTRO_CODE).iso
	cd "$(BUILD)" && sha256sum -b "`basename "$<"`" > "`basename "$@.partial"`"

	mv "$@.partial" "$@"

$(BUILD)/SHA256SUMS.gpg: $(BUILD)/SHA256SUMS
	cd "$(BUILD)" && gpg --batch --yes --output "`basename "$@.partial"`" --detach-sig "`basename "$<"`"

	mv "$@.partial" "$@"
