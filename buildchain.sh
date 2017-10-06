#!/usr/bin/env bash

set -e
shopt -s nullglob

export LC=C.UTF-8
export SOURCE_DATE_EPOCH="$(git log -1 --format='%ct')"

function msg {
    echo -e "\e[1m""$@""\e[0m" >&2
}

export DISTRO_EPOCH="${SOURCE_DATE_EPOCH}"
export DISTRO_DATE="$(date --date=@"${SOURCE_DATE_EPOCH}" +%Y%m%d)"

msg "clean"
make clean

msg "build"
make tar
