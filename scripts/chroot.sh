#!/bin/bash

export HOME=/root
export LC_ALL=C

add-apt-repository -y ppa:system76-dev/stable
apt update -y
apt install -y system76-driver system76-pop-theme

cat > /etc/dconf/profile/user <<EOF
user-db:user
system-db:system76
EOF

mkdir -p /etc/dconf/db/system76.d
cat > /etc/dconf/db/system76.d/00-interface <<EOF
[org/gnome/desktop/background]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/System76-Unleash_Your_Robot_Blue-by_Kate_Hazen_of_System76.png'
primary-color='#000000'
secondary-color='#000000'

[org/gnome/desktop/screensaver]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/System76-Robot-by_Kate_Hazen_of_System76.png'
primary-color='#000000'
secondary-color='#000000'

[org/gnome/desktop/interface]
gtk-theme='Pop'
icon-theme='Pop'
cursor-theme='Pop'
font-name='Fira Sans Semi-Light 10'
document-font-name='Roboto Slab 11'
monospace-font-name='Fira Mono 11'

[org/gnome/desktop/wm/preferences]
titlebar-font='Fira Sans Semi-Bold 10'
EOF

dconf update

#apt full-upgrade
apt clean -y