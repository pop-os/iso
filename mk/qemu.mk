$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@.partial" 16G

	mv "$@.partial" "$@"

qemu_bios: $(ISO) $(BUILD)/qemu.img
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu.img \
		-boot d -cdrom "$<"

qemu_bios_hd: $(BUILD)/qemu.img
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu.img

qemu_uefi: $(ISO) $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI" \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -cdrom "$<"

qemu_uefi_usb: $(ISO) $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI" \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -drive if=none,id=iso,file="$<" \
		-device nec-usb-xhci,id=xhci \
		-device usb-storage,bus=xhci.0,drive=iso

qemu_uefi_hd: $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI" \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-hda $(BUILD)/qemu_uefi.img

qemu_ubuntu_bios: $(BUILD)/ubuntu.iso $(BUILD)/qemu_ubuntu.img
	qemu-system-x86_64 -name "Ubuntu $(DISTRO_VERSION) BIOS" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu_ubuntu.img \
		-boot d -cdrom "$<"

qemu_ubuntu_bios_hd: $(BUILD)/qemu_ubuntu.img
	qemu-system-x86_64 -name "Ubuntu $(DISTRO_VERSION) BIOS" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu_ubuntu.img

qemu_ubuntu_uefi: $(BUILD)/ubuntu.iso $(BUILD)/qemu_ubuntu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "Ubuntu $(DISTRO_VERSION) UEFI" \
		-enable-kvm -m 2048 -vga qxl \
		-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
		-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
		-hda $(BUILD)/qemu_ubuntu_uefi.img \
		-boot d -cdrom "$<"

qemu_ubuntu_uefi_hd: $(BUILD)/qemu_ubuntu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "Ubuntu $(DISTRO_VERSION) UEFI" \
	-enable-kvm -m 2048 -vga qxl \
	-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
	-drive if=pflash,format=raw,file=$(BUILD)/OVMF_VARS.fd \
	-hda $(BUILD)/qemu_ubuntu_uefi.img
