$(BUILD)/ubuntu.iso:
	mkdir -p $(BUILD)

	# Download Ubuntu ISO
	wget -O "$@.partial" "$(UBUNTU_ISO)"

	mv "$@.partial" "$@"

zsync: $(BUILD)/ubuntu.iso
	zsync "$(UBUNTU_ISO).zsync" -o "$<"
