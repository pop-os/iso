$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@.partial" 16G

	mv "$@.partial" "$@"

qemu_bios: $(ISO) $(BUILD)/qemu.img
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS ISO" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu.img \
		-boot d -cdrom "$<"

qemu_bios_hd: $(BUILD)/qemu.img
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS HD" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu.img

qemu_bios_usb: $(USB) $(BUILD)/qemu.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS USB" \
		-enable-kvm -m 2048 -vga qxl \
		-hda "$<" \
		-hdb $(BUILD)/qemu.img \

qemu_uefi: $(ISO) $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI ISO" \
		-enable-kvm -m 2048 -vga qxl \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -cdrom "$<"

qemu_uefi_hd: $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI HD" \
		-enable-kvm -m 2048 -vga qxl \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-hda $(BUILD)/qemu_uefi.img

qemu_uefi_usb: $(USB) $(BUILD)/qemu_uefi.img
	cp /usr/share/OVMF/OVMF_VARS.fd $(BUILD)/OVMF_VARS.fd
	qemu-system-x86_64 -name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI USB" \
		-enable-kvm -m 2048 -vga qxl \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -drive if=none,id=img,file="$<" \
		-device nec-usb-xhci,id=xhci \
		-device usb-storage,bus=xhci.0,drive=img
