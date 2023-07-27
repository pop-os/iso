QEMUFLAGS=\
	-enable-kvm \
	-m 4G \
	-smp 8 \
	-vga qxl

$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@.partial" 32G

	mv "$@.partial" "$@"

qemu_bios: $(ISO) $(BUILD)/qemu.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS ISO" \
		-hda $(BUILD)/qemu.img \
		-boot d -cdrom "$<"

qemu_bios_hd: $(BUILD)/qemu.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS HD" \
		-enable-kvm -m 2048 -vga qxl \
		-hda $(BUILD)/qemu.img

qemu_bios_usb: $(USB) $(BUILD)/qemu.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) BIOS USB" \
		-hda "$<" \
		-hdb $(BUILD)/qemu.img \

qemu_uefi: $(ISO) $(BUILD)/qemu_uefi.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI ISO" \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -cdrom "$<"

qemu_uefi_hd: $(BUILD)/qemu_uefi.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI HD" \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-hda $(BUILD)/qemu_uefi.img

qemu_uefi_usb: $(USB) $(BUILD)/qemu_uefi.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) UEFI USB" \
		-bios /usr/share/OVMF/OVMF_CODE.fd \
		-hda $(BUILD)/qemu_uefi.img \
		-boot d -drive if=none,id=img,file="$<" \
		-device nec-usb-xhci,id=xhci \
		-device usb-storage,bus=xhci.0,drive=img
