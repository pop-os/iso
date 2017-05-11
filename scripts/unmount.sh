#!/bin/bash -e

if [ -z "$1" ]
then
    echo "$0 [chroot directory]"
    exit 1
fi
CHROOT="$(realpath "$1")"

if [ -d "$CHROOT" ]
then
    if [ -n "$(mount | grep "$CHROOT")" ]
    then
        sudo umount "$CHROOT/dev" || sudo umount -lf "$CHROOT/dev" || true
        sudo umount "$CHROOT/run" || sudo umount -lf "$CHROOT/run" || true
        sudo umount "$CHROOT/proc" || sudo umount -lf "$CHROOT/proc" || true
        sudo umount "$CHROOT/sys" || sudo umount -lf "$CHROOT/sys" || true
    fi
    if [ -n "$(mount | grep "$CHROOT")" ]
    then
        echo "$CHROOT still mounted"
        exit 1
    fi
fi
