#!/usr/bin/env bash

set -e -x

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# Generate a machine ID
if [ -n "$(which dbus-uuidgen)" ]
then
    dbus-uuidgen > /var/lib/dbus/machine-id
fi

# Add APT key
if [ -n "${KEY}" ]
then
    echo "Adding APT key: ${KEY}"
    apt-key add "${KEY}"
fi

# Add all distro PPAs
if [ $# -gt 0 ]
then
    for repo in "$@"
    do
        echo "Adding repository '$repo'"
        add-apt-repository -y "$repo"
    done
fi

# Update package definitions
if [ -n "${UPDATE}" ]
then
    apt-get update -y
fi

# Upgrade installed packages
if [ -n "${UPGRADE}" ]
then
    apt-get dist-upgrade -y
fi

# Install packages
if [ -n "${INSTALL}" ]
then
    echo "Installing packages: ${INSTALL}"
    apt-get install -y ${INSTALL}
fi

# Remove packages
if [ -n "${PURGE}" ]
then
    echo "Removing packages: ${PURGE}"
    apt-get purge -y ${PURGE}
fi

# Remove unnecessary packages
if [ -n "${AUTOREMOVE}" ]
then
    apt-get autoremove --purge -y
fi

# Download main pool packages
if [ -n "${MAIN_POOL}" ]
then
    mkdir -p "/iso/pool/main"
    chown -R _apt "/iso/pool/main"
    pushd "/iso/pool/main"
        sudo -u _apt apt-get download ${MAIN_POOL}
    popd
fi

# Download restricted pool packages
if [ -n "${RESTRICTED_POOL}" ]
then
    mkdir -p "/iso/pool/restricted"
    chown -R _apt "/iso/pool/restricted"
    pushd "/iso/pool/restricted"
        sudo -u _apt apt-get download ${RESTRICTED_POOL}
    popd
fi

# Remove apt files
if [ -n "${CLEAN}" ]
then
    apt-get clean -y
fi

# Remove temporary files
rm -rf /tmp/*

# Remove machine ID
rm -f /var/lib/dbus/machine-id
