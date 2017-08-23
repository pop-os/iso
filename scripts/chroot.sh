#!/usr/bin/env bash

set -e -x

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# Generate a machine ID
dbus-uuidgen > /var/lib/dbus/machine-id

# Add all distro PPAs
for repo in ${DISTRO_REPOS}
do
    echo "Adding repository '$repo'"
    add-apt-repository -y "$repo"
done

# Update package definitions
apt-get update -y

# Upgrade installed packages
apt-get dist-upgrade -y

# Install new packages
if [ -n "${DISTRO_PKGS}" -o -n "${LIVE_PKGS}" ]
then
    echo "Installing packages: ${DISTRO_PKGS} ${LIVE_PKGS}"
    apt-get install -y ${DISTRO_PKGS} ${LIVE_PKGS}
fi

if [ -n "${RM_PKGS}" ]
then
    echo "Removing packages: ${RM_PKGS}"
    apt-get purge -y ${RM_PKGS}
fi

# Insuring that kernel is installed
if [ ! -e /vmlinuz ]
then
    apt-get install --reinstall "$(basename $(readlink -f /vmlinuz) | sed 's/vmlinuz/linux-image/')"
fi

# Update initramfs
update-initramfs -u

# Remove unnecessary packages
apt-get autoremove --purge -y

# Update package manifest
dpkg-query -W --showformat='${Package} ${Version}\n' > /iso/filesystem.manifest

# Download main pool packages
mkdir -p "/iso/pool/main"
chown -R _apt "/iso/pool/main"
pushd "/iso/pool/main"
    for pkg in ${MAIN_POOL}
    do
        sudo -u _apt apt-get download "$pkg"
    done
popd

# Download restricted pool packages
mkdir -p "/iso/pool/restricted"
chown -R _apt "/iso/pool/restricted"
pushd "/iso/pool/restricted"
    for pkg in ${RESTRICTED_POOL}
    do
        sudo -u _apt apt-get download "$pkg"
    done
popd

# Remove temporary files
apt-get clean -y
rm -rf /tmp/*

# Remove machine ID
rm /var/lib/dbus/machine-id
