#!/bin/bash -e

if [ -z "$1" ]
then
    echo "$0 [chroot directory]"
    exit 1
fi
CHROOT="$(realpath "$1")"

if [ -d "$CHROOT" ]
then
    sudo mount --bind /dev "$CHROOT/dev"
    sudo mount --bind /run "$CHROOT/run"
    sudo mount --bind /proc "$CHROOT/proc"
    sudo mount --bind /sys "$CHROOT/sys"
fi
