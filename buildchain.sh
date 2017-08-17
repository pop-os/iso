#!/usr/bin/env bash

set -e
shopt -s nullglob

export LC=C.UTF-8
export SOURCE_DATE_EPOCH="$(git log -1 --format='%ct')"

function usage {
    echo "buildchain.sh [destination]" >&2
}

function msg {
    echo -e "\e[1m""$@""\e[0m" >&2
}

if [ -z "$1" ]
then
    usage
    exit 1
fi
DIR="$(realpath "$1")"

mkdir -p "$DIR"

export DISTRO_EPOCH="${SOURCE_DATE_EPOCH}"
export DISTRO_VERSION=17.10

msg "clean"
make clean

msg "build"
make "build/${DISTRO_VERSION}/pop-os.tar"

pushd "build/${DISTRO_VERSION}" > /dev/null
    mv -v pop-os.tar "$DIR"
popd > /dev/null
