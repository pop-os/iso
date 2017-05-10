.PHONY: all clean disk run uefi

all: build/system76.iso

clean:
	rm -f build/system76.iso

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

build/system76.iso:
	mkdir -p build
	cd build && ../scripts/build.sh $(PWD)
