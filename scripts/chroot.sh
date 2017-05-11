#!/bin/bash -e

export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id

add-apt-repository -y ppa:system76-dev/daily
apt update -y
apt install -y \
    system76-driver \
    system76-default-settings \
    plymouth-theme-system76-logo \
    plymouth-theme-system76-text

apt clean -y

dpkg-query -W --showformat='${Package} ${Version}\n' > /filesystem.manifest

rm /var/lib/dbus/machine-id
