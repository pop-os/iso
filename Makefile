.PHONY: all clean disk run

all: build/system76.iso

clean:
	rm -f build/system76.iso

disk: build/system76.iso
	sudo usb-creator-gtk -i "$<"

run: build/system76.iso
	qemu-system-x86_64 -enable-kvm -m 2048 -boot d -cdrom "$<"

build/system76.iso:
	mkdir -p build
	cd build && ../scripts/build.sh $(PWD)