#!/usr/bin/env bash

set -e -x

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# Generate a machine ID
dbus-uuidgen > /var/lib/dbus/machine-id

# Add all distro PPAs
if [ -n "${DISTRO_REPOS}" ]
then
    for repo in ${DISTRO_REPOS}
    do
        echo "Adding repository '$repo'"
        add-apt-repository -y "$repo"
    done
fi

# Update package definitions
apt-get update -y

# Upgrade installed packages
apt-get dist-upgrade -y

# Install distro packages
if [ -n "${DISTRO_PKGS}" ]
then
    echo "Installing distro packages: ${DISTRO_PKGS}"
    apt-get install -y ${DISTRO_PKGS}
fi

# Remove unwanted packages
if [ -n "${RM_PKGS}" ]
then
    echo "Removing packages: ${RM_PKGS}"
    apt-get purge -y ${RM_PKGS}
fi

# Remove unnecessary packages
apt-get autoremove --purge -y

# Download main pool packages
if [ -n "${MAIN_POOL}" ]
then
    mkdir -p "/iso/pool/main"
    chown -R _apt "/iso/pool/main"
    pushd "/iso/pool/main"
        for pkg in ${MAIN_POOL}
        do
            sudo -u _apt apt-get download "$pkg"
        done
    popd
fi

# Download restricted pool packages
if [ -n "${RESTRICTED_POOL}" ]
then
    mkdir -p "/iso/pool/restricted"
    chown -R _apt "/iso/pool/restricted"
    pushd "/iso/pool/restricted"
        for pkg in ${RESTRICTED_POOL}
        do
            sudo -u _apt apt-get download "$pkg"
        done
    popd
fi

# Remove temporary files
apt-get clean -y
rm -rf /tmp/*

# Remove machine ID
rm /var/lib/dbus/machine-id
