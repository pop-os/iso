#!/bin/bash -e

export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id

touch /var/cache/system76-pre-master.marker

for repo in $REPOS
do
    echo "Adding repository '$repo'"
    add-apt-repository -y "$repo"
done

apt update -y

if [ $# -gt 0 ]
then
    echo "Installing packages '$@'"
    apt install -y "$@"
fi

apt clean -y

dpkg-query -W --showformat='${Package} ${Version}\n' > /filesystem.manifest

rm /usr/lib/ubiquity/plugins/ubi-usersetup.py

rm /var/cache/system76-pre-master.marker

rm /var/lib/dbus/machine-id
