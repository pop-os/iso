DISTRO=System76

.PHONY: all clean disk run uefi

all: build/system76.iso

clean:
	rm -f build/*.tag build/system76.iso

run: build/system76.iso
	qemu-system-x86_64 \
		-enable-kvm -m 2048 -vga qxl \
		-boot d -cdrom "$<"

uefi: build/system76.iso
	cp /usr/share/OVMF/OVMF_VARS.fd build/OVMF_VARS.fd
	qemu-system-x86_64 \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=build/OVMF_VARS.fd \
		-boot d -cdrom "$<"

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
	cp "data/README.diskdefines" "build/iso/README.diskdefines"
	cp "data/info" "build/iso/.disk/info"
	cp "data/grub.cfg" "build/iso/boot/grub/grub.cfg"
	cp "data/loopback.cfg" "build/iso/boot/grub/loopback.cfg"
	cp "data/txt.cfg" "build/iso/isolinux/txt.cfg"
	cp "data/splash.pcx" "build/iso/isolinux/splash.pcx"
	cp "data/splash.png" "build/iso/isolinux/splash.png"

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
	sudo chroot "build/chroot" /chroot.sh

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

build/system76.iso: build/iso_modify.tag build/iso_chroot.tag
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
	    -r -V "System76 17.04 amd64" \
		-o "$@" "build/iso"
