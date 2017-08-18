#!/usr/bin/env bash

set -e -x

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
apt-get update -y

# Upgrade installed packages
apt-get upgrade -y

# Install distribution packages
if [ -n "${DISTRO_PKGS}" ]
then
    echo "Installing packages: ${DISTRO_PKGS}"
    apt-get install -y ${DISTRO_PKGS}
fi

# Install ISO packages
if [ -n "${ISO_PKGS}" ]
then
    echo "Installing packages for live install only: ${ISO_PKGS}"
    apt-get install -y ${ISO_PKGS}
fi

if [ -n "${RM_PKGS}" ]
then
    echo "Removing packages: ${RM_PKGS}"
    apt-get purge -y ${RM_PKGS}
fi

# Insuring that kernel and initramfs is installed
apt-get install --reinstall "$(basename $(readlink -f /vmlinuz) | sed 's/vmlinuz/linux-image/')"

# Update initramfs
update-initramfs -u

# Remove unnecessary packages
apt-get autoremove --purge -y

# Clean temporary files
apt-get clean -y

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
