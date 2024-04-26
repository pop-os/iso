#!/bin/bash

gpg --keyserver keyserver.ubuntu.com --recv-keys 204DD8AEC33A7AFF

sudo apt install \
    debootstrap \
    germinate \
    grub-efi-amd64-signed \
    grub-pc-bin \
    isolinux \
    mtools \
    ovmf \
    qemu-efi \
    qemu-kvm \
    qemu-user-static \
    squashfs-tools \
    xorriso \
    zsync
