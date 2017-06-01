DISTRO_NAME=System76

DISTRO_CODE=system76

DISTRO_REPOS=\
	ppa:system76-dev/stable

DISTRO_PKGS=\
	system76-desktop

SED=\
	s|DISTRO_NAME|$(DISTRO_NAME)|g; \
	s|DISTRO_CODE|$(DISTRO_CODE)|g; \
	s|DISTRO_REPOS|$(DISTRO_REPOS)|g; \
	s|DISTRO_PKGS|$(DISTRO_PKGS)|g

.PHONY: all clean iso run uefi

iso: build/$(DISTRO_CODE).iso

all: build/$(DISTRO_CODE).iso build/$(DISTRO_CODE).iso.zsync build/SHA256SUMS build/SHA256SUMS.gpg

clean:
	rm -f build/*.tag build/$(DISTRO_CODE).iso

build/qemu.img:
	mkdir -p build
	qemu-img create -f qcow2 "$@" 16G

run: build/$(DISTRO_CODE).iso build/qemu.img
	qemu-system-x86_64 \
		-enable-kvm -m 2048 -vga qxl \
		-boot d -cdrom "$<"
		#-hda build/qemu.img

uefi: build/$(DISTRO_CODE).iso build/qemu.img
	cp /usr/share/OVMF/OVMF_VARS.fd build/OVMF_VARS.fd
	qemu-system-x86_64 \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=build/OVMF_VARS.fd \
		-boot d -cdrom "$<"
		#-hda build/qemu.img

build/ubuntu.iso:
	mkdir -p build
	wget -O "$@" "http://cdimage.ubuntu.com/ubuntu-gnome/releases/17.04/release/ubuntu-gnome-17.04-desktop-amd64.iso"

build/iso_extract.tag: build/ubuntu.iso
	# Remove old ISO
	rm -rf "build/iso"

	# Extract ISO
	xorriso -acl on -xattr on -osirrox on -indev "$<" -extract / "build/iso"

	# Make readable
	chmod u+w -R "build/iso"

	touch "$@"

build/iso_modify.tag: build/iso_extract.tag
	sed "$(SED)" "data/README.diskdefines" > "build/iso/README.diskdefines"
	sed "$(SED)" "data/info" > "build/iso/.disk/info"
	sed "$(SED)" "data/grub.cfg" > "build/iso/boot/grub/grub.cfg"
	sed "$(SED)" "data/loopback.cfg" > "build/iso/boot/grub/loopback.cfg"
	sed "$(SED)" "data/txt.cfg" > "build/iso/isolinux/txt.cfg"
	sed "$(SED)" "data/preseed.seed" > "build/iso/preseed/$(DISTRO_CODE).seed"

	cp "data/access.pcx" "build/iso/isolinux/access.pcx"
	cp "data/blank.pcx" "build/iso/isolinux/blank.pcx"
	cp "data/gfxboot.cfg" "build/iso/isolinux/gfxboot.cfg"
	cp "data/splash.pcx" "build/iso/isolinux/splash.pcx"
	cp "data/splash.png" "build/iso/isolinux/splash.png"

	rm -rf "build/iso/boot/grub/theme"
	cp -r "data/grub-theme" "build/iso/boot/grub/theme"

	touch "$@"

build/chroot_extract.tag: build/iso_extract.tag
	# Unmount chroot if mounted
	scripts/unmount.sh "build/chroot"

	# Remove old chroot
	sudo rm -rf "build/chroot"

	# Extract squashfs
	sudo unsquashfs -d "build/chroot" "build/iso/casper/filesystem.squashfs"

	touch "$@"

build/chroot_modify.tag: build/chroot_extract.tag
	# Unmount chroot if mounted
	"scripts/unmount.sh" "build/chroot"

	# Mount chroot
	"scripts/mount.sh" "build/chroot"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "build/chroot/chroot.sh"

	# Run chroot script
	sudo chroot "build/chroot" /bin/bash -e -c "REPOS=\"$(DISTRO_REPOS)\" /chroot.sh $(DISTRO_PKGS)"

	# Remove chroot script
	sudo rm "build/chroot/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "build/chroot"

	touch "$@"

build/iso_chroot.tag: build/chroot_modify.tag
	# Rebuild filesystem image
	sudo mksquashfs "build/chroot" "build/iso/casper/filesystem.squashfs" -noappend

	# Rebuild initrd
	sudo gzip -dc "build/chroot/initrd.img" | lzma -7 > "build/iso/casper/initrd.lz"

	# Update manifest
	sudo cp "build/chroot/filesystem.manifest" "build/iso/casper/filesystem.manifest"

	# Update filesystem size
	sudo du -sx --block-size=1 "build/chroot" | cut -f1 > "build/iso/casper/filesystem.size"

	touch "$@"

build/$(DISTRO_CODE).iso: build/iso_modify.tag build/iso_chroot.tag
	# Regenerate bootlogo
	scripts/bootlogo.sh "build/iso" "build/bootlogo"

	# Calculate md5sum
	cd "build/iso" && sudo bash -e -c "rm md5sum.txt && find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat > md5sum.txt"

	xorriso -as mkisofs \
	    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
	    -c isolinux/boot.cat -b isolinux/isolinux.bin \
	    -no-emul-boot -boot-load-size 4 -boot-info-table \
	    -eltorito-alt-boot -e boot/grub/efi.img \
	    -no-emul-boot -isohybrid-gpt-basdat \
	    -r -V "$(DISTRO_NAME) 17.04 amd64" \
		-o "$@" "build/iso"

build/$(DISTRO_CODE).iso.zsync: build/$(DISTRO_CODE).iso
	cd build && zsyncmake -o "`basename "$@"`" "`basename "$<"`"

build/SHA256SUMS: build/$(DISTRO_CODE).iso
	cd build && sha256sum -b "`basename "$<"`" > "`basename "$@"`"

build/SHA256SUMS.gpg: build/SHA256SUMS
	cd build && gpg --output "`basename "$@"`" --detach-sig "`basename "$<"`"
