#!/bin/bash -e

function usage {
    echo "$0 [iso directory] [bootlogo directory] [epoch timestamp]"
}

if [ ! -d "$1" ]
then
    usage
    exit 1
fi
ISODIR="$(realpath "$1")"

if [ -z "$2" ]
then
    usage
    exit 1
fi
BOOTLOGO="$(realpath "$2")"

if [ -z "$3" ]
then
    usage
    exit 1
fi
DISTRO_EPOCH="$3"

rm -rf "$BOOTLOGO"
mkdir -p "$BOOTLOGO"
pushd "$BOOTLOGO" > /dev/null
    cpio --extract --quiet --make-directories < "$ISODIR/isolinux/bootlogo"
    for file in $(find . -type f)
    do
        if [ -f "$ISODIR/isolinux/$file" ]
        then
            cp "$ISODIR/isolinux/$file" "$file"
        fi
    done
    find . -exec touch -h -d @"${DISTRO_EPOCH}" {} \;
    find . | sort | cpio --create --quiet --reproducible --owner=0:0 > "$ISODIR/isolinux/bootlogo"
popd > /dev/null
