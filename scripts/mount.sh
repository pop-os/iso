#!/bin/bash -e

if [ -z "$1" ]
then
    echo "$0 [chroot directory]"
    exit 1
fi
CHROOT="$(realpath "$1")"

if [ -d "$CHROOT" ]
then
    sudo mount -o bind /dev "$CHROOT/dev"
    sudo mount -o bind /run "$CHROOT/run"
    sudo mount -t proc proc "$CHROOT/proc"
    sudo mount -t sysfs sys "$CHROOT/sys"
fi
