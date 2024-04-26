ifeq ($(DISTRO_ARCH),amd64)
QEMU=qemu-system-x86_64
QEMUFLAGS=\
	-enable-kvm \
	-m 4G \
	-smp 8 \
	-vga qxl
ifeq ($(efi),no)
QEMUFLAGS+=-bios /usr/share/OVMF/OVMF_CODE.fd
BOOTLOADER=UEFI
else
BOOTLOADER=BIOS
endif
else ifeq ($(DISTRO_ARCH),arm64)
QEMU=qemu-system-aarch64
QEMUFLAGS=\
	-m 4G \
	-smp 8 \
	-vga qxl
BOOTLOADER=UEFI
else
$(error unknown DISTRO_ARCH $(DISTRO_ARCH))
endif

$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@.partial" 64G
	mv "$@.partial" "$@"

qemu: $(ISO) $(BUILD)/qemu.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) ISO" \
		-hda $(BUILD)/qemu.img \
		-boot d -cdrom "$<"

qemu_hd: $(BUILD)/qemu.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) HD" \
		-hda $(BUILD)/qemu.img

qemu_usb: $(ISO) $(BUILD)/qemu.img
	qemu-system-x86_64 $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) USB" \
		-hda $(BUILD)/qemu.img \
		-boot d -drive if=none,id=img,file="$<" \
		-device nec-usb-xhci,id=xhci \
		-device usb-storage,bus=xhci.0,drive=img
