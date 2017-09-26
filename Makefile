# Configuration settings
include mk/config.mk

# Standard target - build the ISO
iso: $(ISO)

# Complete target - build zsync file, SHA256SUMS, and GPG signature
all: $(ISO) $(ISO).zsync $(BUILD)/SHA256SUMS $(BUILD)/SHA256SUMS.gpg

# Clean target
include mk/clean.mk

# QEMU targets
include mk/qemu.mk

# Chroot targets
include mk/chroot.mk

# Update targets
include mk/update.mk

# ISO targets
include mk/iso.mk

$(BUILD)/ubuntu.iso:
	mkdir -p $(BUILD)

	# Download Ubuntu ISO
	wget -O "$@.partial" "$(UBUNTU_ISO)"

	mv "$@.partial" "$@"

zsync: $(BUILD)/ubuntu.iso
	zsync "$(UBUNTU_ISO).zsync" -o "$<"
