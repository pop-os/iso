#!/bin/bash

gpg --keyserver keyserver.ubuntu.com --recv-keys 204DD8AEC33A7AFF

sudo apt install \
    debootstrap \
    germinate \
    grub-efi-arm64 \
    isolinux \
    mtools \
    ovmf \
    qemu-efi-aarch64 \
    qemu-system-arm \
    qemu-user-static \
    squashfs-tools \
    xorriso \
    zsync

