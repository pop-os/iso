#!/bin/bash -e

set -e -x

if [ -z "$1" ]
then
    echo "$0 [chroot directory]"
    exit 1
fi
CHROOT="$(realpath "$1")"

if [ -d "$CHROOT" ]
then
    sudo mount --bind /dev "$CHROOT/dev"
    sudo mount --bind /dev/pts "$CHROOT/dev/pts"
    sudo mount -t tmpfs run "$CHROOT/run" -o mode=0755,nosuid,nodev
    sudo mount -t proc proc "$CHROOT/proc" -o nosuid,nodev,noexec
    sudo mount -t sysfs sys "$CHROOT/sys" -o nosuid,nodev,noexec,ro
fi
