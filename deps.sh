#!/bin/bash

gpg --keyserver keyserver.ubuntu.com --recv-keys 204DD8AEC33A7AFF

PACKAGES=(
    debootstrap
    germinate
    isolinux
    mtools
    ovmf
    qemu-kvm
    qemu-user-static
    squashfs-tools
    xorriso
    zsync
)
case "$(dpkg --print-architecture)" in
    amd64)
        PACKAGES+=(
            qemu-efi
            grub-efi-amd64-signed
            grub-pc-bin
        )
        ;;
    arm64)
        PACKAGES+=(
            grub-efi-arm64-signed
        )
        ;;
    *)
        ;;
esac
sudo apt install "${PACKAGES[@]}"
