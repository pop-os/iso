#!/bin/bash

export HOME=/root
export LC_ALL=C

add-apt-repository -y ppa:system76-dev/daily
apt update -y
apt purge -y \
    ubuntu-gnome-default-settings \
    plymouth-theme-ubuntu-gnome-logo \
    plymouth-theme-ubuntu-gnome-text
apt install -y \
    system76-default-settings \
    plymouth-theme-system76-logo \
    plymouth-theme-system76-text
#apt full-upgrade
apt clean -y
