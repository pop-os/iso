#!/bin/bash -e

function usage {
    echo "$0 [iso directory] [bootlogo directory]"
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

rm -rf "$BOOTLOGO"
mkdir -p "$BOOTLOGO"
pushd "$BOOTLOGO"
    cpio -id < "$ISODIR/isolinux/bootlogo"
    for file in $(find . -type f)
    do
        if [ -f "$ISODIR/isolinux/$file" ]
        then
            cp "$ISODIR/isolinux/$file" "$file"
        fi
    done
    sudo bash -e -c "find . | cpio --quiet -o > \"$ISODIR/isolinux/bootlogo\""
popd
