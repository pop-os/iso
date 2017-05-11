#!/bin/bash -e

DISTRO="System76"

if [ ! -d "$1" ]
then
    echo "no source directory provided"
    echo "$0 [directory]"
    exit 1
fi

if [ ! -f /usr/lib/ISOLINUX/isolinux.bin ]
then
    sudo apt install -y isolinux
fi

if [ -z "$(which mksquashfs)" ]
then
	sudo apt install -y squashfs-tools
fi

if [ -z "$(which xorriso)" ]
then
    sudo apt install -y xorriso
fi

function mount_chroot {
    sudo mount -o bind /dev ubuntu/dev
    sudo mount -o bind /run ubuntu/run
    sudo mount -t proc proc ubuntu/proc
    sudo mount -t sysfs sys ubuntu/sys
}

function unmount_chroot {
    sudo umount ubuntu/dev || sudo umount -lf ubuntu/dev || true
    sudo umount ubuntu/run || sudo umount -lf ubuntu/run || true
    sudo umount ubuntu/proc || sudo umount -lf ubuntu/proc || true
    sudo umount ubuntu/sys || sudo umount -lf ubuntu/sys || true
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
    sudo umount ubuntu.mount || sudo umount -lf ubuntu.mount || true
}

# Remove mounts for new ISO
if [ -d system76.mount ]
then
    sudo rm -r system76.mount
fi

# Remove old initrd extract
rm -rf initrd initrd.lz

# Remove old bootlogo extract
rm -rf bootlogo bootlogo.img

# Unmount and remove mounts for old ISO
unmount_iso
if [ -d ubuntu.mount ]
then
    rm -r ubuntu.mount
fi

# Clean old chroot
clean_chroot

# Download ISO
if [ ! -f ubuntu.iso ]
then
    wget -O ubuntu.iso http://cdimage.ubuntu.com/ubuntu-gnome/releases/17.04/release/ubuntu-gnome-17.04-desktop-amd64.iso
fi

# Copy squashfs from ISO
mount_iso
    mkdir -p system76.mount
    sudo cp -ruT ubuntu.mount system76.mount
unmount_iso

# Extract squashfs
sudo unsquashfs -d ubuntu system76.mount/casper/filesystem.squashfs

# Run chroot script
mount_chroot
    dbus-uuidgen | sudo tee ubuntu/var/lib/dbus/machine-id
    sudo cp "$1/scripts/chroot.sh" ubuntu/chroot.sh

    sudo chroot ubuntu /chroot.sh
    sudo chroot ubuntu dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee system76.mount/casper/filesystem.manifest

    sudo rm ubuntu/chroot.sh
    sudo rm ubuntu/var/lib/dbus/machine-id
unmount_chroot

# Rebuild initrd
mkdir -p initrd
pushd initrd
    gzip -dc ../ubuntu/initrd.img | cpio -id
    find . | cpio --quiet -o -H newc | lzma -7 > ../initrd.lz
popd
sudo mv initrd.lz system76.mount/casper/initrd.lz

# Compress squashfs
sudo mksquashfs ubuntu system76.mount/casper/filesystem.squashfs -noappend

# Calculate filesystem size
sudo du -sx --block-size=1 ubuntu | cut -f1 | sudo tee system76.mount/casper/filesystem.size

# Change disk name
sudo sed -i "s/Ubuntu-GNOME/$DISTRO/g" system76.mount/README.diskdefines
sudo sed -i "s/Ubuntu-GNOME/$DISTRO/g" system76.mount/.disk/info
sudo sed -i "s/Ubuntu GNOME/$DISTRO/g" system76.mount/boot/grub/grub.cfg
sudo sed -i "s/Ubuntu GNOME/$DISTRO/g" system76.mount/boot/grub/loopback.cfg
sudo sed -i "s/Ubuntu GNOME/$DISTRO/g" system76.mount/isolinux/txt.cfg

# Change splash
sudo cp "$1/data/splash.pcx" system76.mount/isolinux/splash.pcx
sudo cp "$1/data/splash.png" system76.mount/isolinux/splash.png

# Rebuild bootlogo
mkdir -p bootlogo
pushd bootlogo
    cpio -id < ../system76.mount/isolinux/bootlogo
    for file in $(find . -type f)
    do
        if [ -f "../system76.mount/isolinux/$file" ]
        then
            cp "../system76.mount/isolinux/$file" "$file"
        fi
    done
    find . | cpio --quiet -o > ../bootlogo.img
popd
sudo mv bootlogo.img system76.mount/isolinux/bootlogo

# Calculate md5sum
pushd system76.mount
    sudo rm md5sum.txt
    find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
popd

# Get correct volume label
LABEL="$(isoinfo -d -i ubuntu.iso | grep '^Volume id: ' | cut -d ' ' -f3- | sed "s/Ubuntu-GNOME/$DISTRO/g")"

# Create new ISO
xorriso -as mkisofs \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -c isolinux/boot.cat -b isolinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot -e boot/grub/efi.img \
    -no-emul-boot -isohybrid-gpt-basdat \
    -r -V "$LABEL" \
    -o system76.iso system76.mount
