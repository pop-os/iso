#!/bin/bash

export HOME=/root
export LC_ALL=C

add-apt-repository -y ppa:system76-dev/daily
apt update -y
apt purge -y \
    ubuntu-gnome-desktop \
    ubuntu-gnome-default-settings \
    plymouth-theme-ubuntu-gnome-logo \
    plymouth-theme-ubuntu-gnome-text
apt autoremove -y --purge
apt install -y \
    system76-driver \
    system76-default-settings
#apt full-upgrade
apt clean -y

bash