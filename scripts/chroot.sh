#!/bin/bash -e

export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id

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

rm /var/lib/dbus/machine-id
