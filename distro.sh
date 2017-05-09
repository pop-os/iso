#!/bin/bash

mkdir -p build
cd build

function mount_chroot {
    sudo mount -o bind /dev ubuntu/dev
    sudo mount -o bind /run ubuntu/run
    sudo mount -t proc proc ubuntu/proc
    sudo mount -t sysfs sys ubuntu/sys
}

function unmount_chroot {
    sudo umount ubuntu/dev || sudo umount -lf ubuntu/dev
    sudo umount ubuntu/run || sudo umount -lf ubuntu/run
    sudo umount ubuntu/proc || sudo umount -lf ubuntu/proc
    sudo umount ubuntu/sys || sudo umount -lf ubuntu/sys
}

function clean_chroot {
    unmount_chroot

    if [ -n "$(mount | grep "$PWD/ubuntu")" ]
    then
        echo "ubuntu chroot still mounted"
        exit 1
    fi

    if [ -d ubuntu ]
    then
        sudo rm -rf ubuntu
    fi
}

function mount_iso {
    mkdir -p ubuntu.mount
    sudo mount -o loop ubuntu.iso ubuntu.mount
}

function unmount_iso {
    sudo umount ubuntu.mount || sudo umount -lf ubuntu.mount
}

# Remove mounts for new ISO
if [ -d system76.mount ]
then
    sudo rm -r system76.mount || exit 1
fi

# Unmount and remove mounts for old ISO
unmount_iso
if [ -d ubuntu.mount ]
then
    rm -r ubuntu.mount || exit 1
fi

# Clean old chroot
clean_chroot || exit 1

# Download ISO
if [ ! -f ubuntu.iso ]
then
    wget -O ubuntu.iso http://cdimage.ubuntu.com/ubuntu-gnome/releases/17.04/release/ubuntu-gnome-17.04-desktop-amd64.iso || exit 1
fi

# Copy squashfs from ISO
mount_iso || exit 1
    mkdir -p system76.mount
    sudo cp -ruT ubuntu.mount system76.mount
unmount_iso

# Extract squashfs
sudo unsquashfs -d ubuntu system76.mount/casper/filesystem.squashfs || exit 1

# Run chroot script
mount_chroot
    dbus-uuidgen | sudo tee ubuntu/var/lib/dbus/machine-id
    sudo cp ../chroot.sh ubuntu/chroot.sh

    sudo chroot ubuntu /chroot.sh

    sudo rm ubuntu/chroot.sh
    sudo rm ubuntu/var/lib/dbus/machine-id
unmount_chroot

# Compress squashfs
sudo mksquashfs ubuntu system76.mount/casper/filesystem.squashfs -noappend || exit 1

# Calculate filesystem size
sudo du -sx --block-size=1 ubuntu | cut -f1 | sudo tee system76.mount/casper/filesystem.size

# Create new ISO
sudo xorriso -as mkisofs \
    -eltorito-alt-boot -e boot/grub/efi.img \
    -no-emul-boot -isohybrid-gpt-basdat \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -c isolinux/boot.cat -b isolinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -o system76.iso system76.mount