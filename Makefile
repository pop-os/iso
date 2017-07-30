DISTRO_VERSION?=17.04

DISTRO_DATE=`date +%Y%M%d`

DISTRO_NAME=Pop_OS

DISTRO_CODE=pop-os

DISTRO_REPOS=\
	universe \
	ppa:system76/pop

DISTRO_PKGS=\
	pop-desktop \
	ubiquity-slideshow-pop

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
	UBUNTU_NAME=Zesty Zapus
	UBUNTU_CODE=zesty
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

.PHONY: all clean iso qemu qemu_uefi qemu_ubuntu qemu_ubuntu_uefi zsync

iso: $(BUILD)/$(DISTRO_CODE).iso

all: $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/$(DISTRO_CODE).iso.zsync $(BUILD)/SHA256SUMS $(BUILD)/SHA256SUMS.gpg

clean:
	rm -f $(BUILD)/*.tag $(BUILD)/*.img $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/$(DISTRO_CODE).iso.zsync $(BUILD)/SHA256SUMS $(BUILD)/SHA256SUMS.gpg

$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@" 16G

qemu: $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/qemu.img
	qemu-system-x86_64 \
		-enable-kvm -m 2048 -vga qxl \
		-boot d -cdrom "$<" \
		-hda $(BUILD)/qemu.img

qemu_uefi: $(BUILD)/$(DISTRO_CODE).iso $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-boot d -cdrom "$<" \
		-hda $(BUILD)/qemu_uefi.img

qemu_ubuntu: $(BUILD)/ubuntu.iso $(BUILD)/qemu.img
	qemu-system-x86_64 \
	-enable-kvm -m 2048 -vga qxl \
	-boot d -cdrom "$<" \
	-hda $(BUILD)/qemu.img

qemu_ubuntu_uefi: $(BUILD)/ubuntu.iso $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-boot d -cdrom "$<" \
		-hda $(BUILD)/qemu_uefi.img

$(BUILD)/ubuntu.iso:
	mkdir -p $(BUILD)
	wget -O "$@" "$(UBUNTU_ISO)"

zsync: $(BUILD)/ubuntu.iso
	zsync "$(UBUNTU_ISO).zsync" -o "$<"

$(BUILD)/iso_extract.tag: $(BUILD)/ubuntu.iso

	# Remove old ISO
	sudo rm -rf "$(BUILD)/iso"

	# Extract ISO
	xorriso -acl on -xattr on -osirrox on -indev "$<" -extract / "$(BUILD)/iso"

	# Make readable
	chmod u+w -R "$(BUILD)/iso"

	touch "$@"

$(BUILD)/iso_modify.tag: $(BUILD)/iso_extract.tag
	git submodule update --init data/default-settings

	sed "$(SED)" "data/README.diskdefines" > "$(BUILD)/iso/README.diskdefines"
	sed "$(SED)" "data/info" > "$(BUILD)/iso/.disk/info"
	sed "$(SED)" "data/preseed.seed" > "$(BUILD)/iso/preseed/$(DISTRO_CODE).seed"

	sed "$(SED)" "data/grub/grub.cfg" > "$(BUILD)/iso/boot/grub/grub.cfg"
	sed "$(SED)" "data/grub/loopback.cfg" > "$(BUILD)/iso/boot/grub/loopback.cfg"

	cp "data/isolinux/access.pcx" "$(BUILD)/iso/isolinux/access.pcx"
	cp "data/isolinux/blank.pcx" "$(BUILD)/iso/isolinux/blank.pcx"
	sed "$(SED)" "data/isolinux/gfxboot.cfg" > "$(BUILD)/iso/isolinux/gfxboot.cfg"
	sed "$(SED)" "data/isolinux/isolinux.cfg" > "$(BUILD)/iso/isolinux/isolinux.cfg"
	cp "data/isolinux/splash.pcx" "$(BUILD)/iso/isolinux/splash.pcx"
	sed "$(SED)" "data/isolinux/txt.cfg" > "$(BUILD)/iso/isolinux/txt.cfg"

	rm -rf "$(BUILD)/iso/boot/grub/themes"
	cp -r "data/default-settings/usr/share/grub/themes" "$(BUILD)/iso/boot/grub/themes"

	touch "$@"

$(BUILD)/chroot_extract.tag: $(BUILD)/iso_extract.tag
	# Unmount chroot if mounted
	scripts/unmount.sh "$(BUILD)/chroot"

	# Remove old chroot
	sudo rm -rf "$(BUILD)/chroot"

	# Extract squashfs
	sudo unsquashfs -d "$(BUILD)/chroot" "$(BUILD)/iso/casper/filesystem.squashfs"

	touch "$@"

$(BUILD)/chroot_modify.tag: $(BUILD)/chroot_extract.tag
	# Unmount chroot if mounted
	"scripts/unmount.sh" "$(BUILD)/chroot"

	# Make temp directory for modifications
	sudo rm -rf "$(BUILD)/chroot/iso"
	sudo mkdir -p "$(BUILD)/chroot/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$(BUILD)/chroot/iso/chroot.sh"

	# Mount chroot
	"scripts/mount.sh" "$(BUILD)/chroot"

	# Run chroot script
	sudo chroot "$(BUILD)/chroot" /bin/bash -e -c \
		"DISTRO_NAME=\"$(DISTRO_NAME)\" \
		DISTRO_CODE=\"$(DISTRO_CODE)\" \
		DISTRO_VERSION=\"$(DISTRO_VERSION)\" \
		DISTRO_REPOS=\"$(DISTRO_REPOS)\" \
		DISTRO_PKGS=\"$(DISTRO_PKGS)\" \
		MAIN_POOL=\"$(MAIN_POOL)\" \
		RESTRICTED_POOL=\"$(RESTRICTED_POOL)\" \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$(BUILD)/chroot"

	# Update manifest
	sudo cp "$(BUILD)/chroot/iso/filesystem.manifest" "$(BUILD)/iso/casper/filesystem.manifest"

	# Copy new dists
	sudo rm -rf "$(BUILD)/iso/pool"
	sudo cp -r "$(BUILD)/chroot/iso/pool" "$(BUILD)/iso/pool"

	# Update pool package lists
	cd $(BUILD)/iso && \
	for pool in $$(ls -1 pool); do \
		apt-ftparchive packages "pool/$$pool" | gzip > "dists/$(UBUNTU_CODE)/$$pool/binary-amd64/Packages.gz"; \
	done

	# Remove temp directory for modifications
	sudo rm -rf "$(BUILD)/chroot/iso"

	# Patch ubiquity by removing plugins and updating order
	sudo sed -i "s/AFTER = .*\$$/AFTER = 'language'/" "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-console-setup.py"
	sudo sed -i "s/AFTER = .*\$$/AFTER = 'console_setup'/" "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-partman.py"
	sudo sed -i "s/AFTER = .*\$$/AFTER = 'partman'/" "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-timezone.py"
	sudo rm -f "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-prepare.py"
	sudo rm -f "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-network.py"
	sudo rm -f "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-tasks.py"
	sudo rm -f "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-usersetup.py"
	sudo rm -f "$(BUILD)/chroot/usr/lib/ubiquity/plugins/ubi-wireless.py"

	touch "$@"

$(BUILD)/iso_chroot.tag: $(BUILD)/chroot_modify.tag
	# Rebuild filesystem image
	sudo mksquashfs "$(BUILD)/chroot" "$(BUILD)/iso/casper/filesystem.squashfs" -noappend

	# Copy vmlinuz
	sudo cp "$(BUILD)/chroot/vmlinuz" "$(BUILD)/iso/casper/vmlinuz.efi"

	# Rebuild initrd
	sudo gzip -dc "$(BUILD)/chroot/initrd.img" | lzma -7 > "$(BUILD)/iso/casper/initrd.lz"

	# Update filesystem size
	sudo du -sx --block-size=1 "$(BUILD)/chroot" | cut -f1 > "$(BUILD)/iso/casper/filesystem.size"

	touch "$@"

$(BUILD)/$(DISTRO_CODE).iso: $(BUILD)/iso_modify.tag $(BUILD)/iso_chroot.tag
	# Regenerate bootlogo
	scripts/bootlogo.sh "$(BUILD)/iso" "$(BUILD)/bootlogo"

	# Calculate md5sum
	cd "$(BUILD)/iso" && sudo bash -e -c "rm md5sum.txt && find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat > md5sum.txt"

	xorriso -as mkisofs \
	    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
	    -c isolinux/boot.cat -b isolinux/isolinux.bin \
	    -no-emul-boot -boot-load-size 4 -boot-info-table \
	    -eltorito-alt-boot -e boot/grub/efi.img \
	    -no-emul-boot -isohybrid-gpt-basdat \
	    -r -V "$(DISTRO_NAME) $(DISTRO_VERSION) amd64" \
		-o "$@" "$(BUILD)/iso"

$(BUILD)/$(DISTRO_CODE).iso.zsync: $(BUILD)/$(DISTRO_CODE).iso
	cd "$(BUILD)" && zsyncmake -o "`basename "$@"`" "`basename "$<"`"

$(BUILD)/SHA256SUMS: $(BUILD)/$(DISTRO_CODE).iso
	cd "$(BUILD)" && sha256sum -b "`basename "$<"`" > "`basename "$@"`"

$(BUILD)/SHA256SUMS.gpg: $(BUILD)/SHA256SUMS
	cd "$(BUILD)" && gpg --batch --yes --output "`basename "$@"`" --detach-sig "`basename "$<"`"
