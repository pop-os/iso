#!/bin/bash -e

export HOME=/root
export LC_ALL=C

add-apt-repository -y ppa:system76-dev/stable
apt update -y
apt install -y system76-driver system76-pop-theme

dconf write /org/gnome/desktop/interface/gtk-theme "'Pop'"
dconf write /org/gnome/desktop/interface/icon-theme "'Pop'"
dconf write /org/gnome/desktop/interface/cursor-theme "'Pop'"

dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Fira Sans Semi-Bold 10'"
dconf write /org/gnome/desktop/interface/font-name "'Fira Sans Semi-Light 10'"
dconf write /org/gnome/desktop/interface/document-font-name "'Roboto Slab 11'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'Fira Mono 11'"

#apt full-upgrade
apt clean -y