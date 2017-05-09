#!/bin/bash -e

export HOME=/root
export LC_ALL=C

add-apt-repository -y ppa:system76-dev/stable
apt update -y
apt install -y system76-driver system76-pop-theme
#apt full-upgrade
apt clean -y