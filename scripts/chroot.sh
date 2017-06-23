#!/bin/bash -e

export HOME=/root
export LC_ALL=C

# Generate a machine ID
dbus-uuidgen > /var/lib/dbus/machine-id

# Create marker that prevents System76 Driver from running
touch /var/cache/system76-pre-master.marker

# Add all distro PPAs
for repo in ${DISTRO_REPOS}
do
    echo "Adding repository '$repo'"
    add-apt-repository -y "$repo"
done

# Update package definitions
apt update -y

# Upgrade installed packages
apt upgrade -y

# Install distribution packages
if [ $# -gt 0 ]
then
    echo "Installing packages '$@'"
    apt install -y "$@"
fi

# Remove unnecessary packages
apt autoremove --purge -y

# Clean temporary files
apt clean -y

# Update package manifest
dpkg-query -W --showformat='${Package} ${Version}\n' > /iso/filesystem.manifest

# Download main pool packages
mkdir -p "/iso/pool/main"
pushd "/iso/pool/main"
    for pkg in ${MAIN_POOL}
    do
        apt-get download "$pkg"
    done
popd

# Download restricted pool packages
mkdir -p "/iso/pool/restricted"
pushd "/iso/pool/restricted"
    for pkg in ${RESTRICTED_POOL}
    do
        apt-get download "$pkg"
    done
popd

# Remove marker that prevents System76 Driver from running
rm /var/cache/system76-pre-master.marker

# Remove machine ID
rm /var/lib/dbus/machine-id

# Update OS release
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

# Remove ubi-usersetup
rm -f /usr/lib/ubiquity/plugins/ubi-usersetup.py
