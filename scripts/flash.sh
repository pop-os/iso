#!/usr/bin/env bash

set -e

if [ ! -f "$1" ]
then
    echo "$1" is not a file >&2
    exit 1
fi

if [ ! -b "$2" ]
then
    echo "$2" is not a block device >&2
    exit 1
fi

if [ ! -z "$(cut /proc/mounts -d ' ' -f1 | grep "$2")" ]
then
    echo "$2" is still mounted >&2
    exit 1
fi

echo "Are you sure you want to flash $1 to $2 (y/N)?" >&2
read confirm

if [ "${confirm}" == "y" ]
then
    pv "$1" | sudo dd bs=8M oflag=sync of="$2"
    sync
else
    echo "Cancelled flash"
    exit 1
fi
