#!/bin/bash -e

export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id

touch /var/cache/system76-pre-master.marker

for repo in ${DISTRO_REPOS}
do
    echo "Adding repository '$repo'"
    add-apt-repository -y "$repo"
done

apt update -y

apt upgrade -y

if [ $# -gt 0 ]
then
    echo "Installing packages '$@'"
    apt install -y "$@"
fi

apt autoremove --purge -y

apt clean -y

dpkg-query -W --showformat='${Package} ${Version}\n' > /filesystem.manifest

cat > /etc/os-release <<EOF
NAME="${DISTRO_NAME}"
VERSION="17.04 (Zesty Zapus)"
ID=${DISTRO_CODE}
ID_LIKE=debian ubuntu
PRETTY_NAME="${DISTRO_NAME} 17.04"
VERSION_ID="17.04"
HOME_URL="http://www.system76.com"
SUPPORT_URL="http://support.system76.com"
BUG_REPORT_URL="https://github.com/system76/distro"
PRIVACY_POLICY_URL="https://system76.com/privacy"
VERSION_CODENAME=zesty
UBUNTU_CODENAME=zesty
EOF

rm -f /usr/lib/ubiquity/plugins/ubi-usersetup.py

rm /var/cache/system76-pre-master.marker

rm /var/lib/dbus/machine-id
