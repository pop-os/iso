# Common flags
QEMUFLAGS=-m 4G -smp 8

# Flags per arch
ifeq ($(DISTRO_ARCH),amd64)
QEMU=qemu-system-x86_64
QEMUFLAGS+=-vga qxl
ifeq ($(efi),no)
BOOTLOADER=BIOS
else
BOOTLOADER=UEFI
QEMUFLAGS+=-bios /usr/share/OVMF/OVMF_CODE.fd
endif
else ifeq ($(DISTRO_ARCH),arm64)
QEMU=qemu-system-aarch64
QEMUFLAGS+=\
	-M virt \
	-vga none \
	-device virtio-gpu-pci \
	-device qemu-xhci -device usb-kbd -device usb-tablet \
	-device ich9-intel-hda -device hda-output \
	-netdev user,id=net0 -device e1000,netdev=net0
BOOTLOADER=UEFI
QEMUFLAGS+=-bios /usr/share/AAVMF/AAVMF_CODE.fd
else
$(error unknown DISTRO_ARCH $(DISTRO_ARCH))
endif

# Enable KVM if host arch matches distro arch
ifeq ($(DISTRO_ARCH),$(shell dpkg --print-architecture))
	QEMUFLAGS+=-enable-kvm -cpu host
else
	QEMUFLAGS+=-cpu max
endif

$(BUILD)/%.img:
	mkdir -p $(BUILD)
	qemu-img create -f qcow2 "$@.partial" 64G
	mv "$@.partial" "$@"

qemu: $(ISO) $(BUILD)/qemu.img
	$(QEMU) $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) ISO" \
		-hda $(BUILD)/qemu.img \
		-boot d -cdrom "$<"

qemu_hd: $(BUILD)/qemu.img
	$(QEMU) $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) HD" \
		-hda $(BUILD)/qemu.img

qemu_usb: $(ISO) $(BUILD)/qemu.img
	$(QEMU) $(QEMUFLAGS) \
		-name "$(DISTRO_NAME) $(DISTRO_VERSION) $(DISTRO_ARCH) $(BOOTLOADER) USB" \
		-hda $(BUILD)/qemu.img \
		-boot d -drive if=none,id=img,file="$<" \
		-device nec-usb-xhci,id=xhci \
		-device usb-storage,bus=xhci.0,drive=img
