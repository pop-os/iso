.PHONY: all clean run

all: build/system76.iso

clean:
	rm -f build/system76.iso

run: build/system76.iso
	qemu-system-x86_64 -enable-kvm -m 2048 -cdrom "$<"

build/system76.iso:
	mkdir -p build
	cd build && ../scripts/build.sh ../scripts/chroot.sh