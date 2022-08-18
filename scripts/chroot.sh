#!/usr/bin/env bash

set -e -x

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# Generate a machine ID
if [ -n "$(which dbus-uuidgen)" ]
then
    dbus-uuidgen > /etc/machine-id
    ln -sf /etc/machine-id /var/lib/dbus/machine-id
fi

if [ ! -f /run/systemd/resolve/stub-resolv.conf ]
then
    mkdir -p /run/systemd/resolve
    echo "nameserver 1.1.1.1" > /run/systemd/resolve/stub-resolv.conf
fi

# Correctly specify resolv.conf
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Enable i386 so that steam is installable out of the box
dpkg --add-architecture i386

# Add APT key
if [ -n "${KEY}" ]
then
    echo "Adding APT key: ${KEY}"
    apt-key add "${KEY}"
    echo $KEY
fi

# Add all distro PPAs
if [ $# -gt 0 ]
then
    echo "Enabling repository source"
    UBUNTU_CODENAME=jammy
    REPOS="http://apt.pop-os.org/staging/"
		for newrepo in "$@"
		do
		    echo "Adding preference for '$newrepo'"
			  tee "/etc/apt/preferences.d/pop-os-staging-${newrepo//./_}" > /dev/null <<-EOF
Package: *
Pin: release o=pop-os-staging-$newrepo
Pin-Priority: 1002
EOF

			  echo "Adding repository for '$newrepo'"
			  LINE="deb ${REPOS}$newrepo ${UBUNTU_CODENAME} main"
			  if command -v apt-manage
			  then
				    apt-manage add "${LINE}" \
					       --source-code \
					       --ident "popdev-${LOCALREMOTE}${newrepo//./-}" \
					       --name "Pop Development Branch $newrepo"
			  else
				    add-apt-repository --enable-source --no-update "${LINE}"
			  fi
    done
    cat /etc/apt/sources.list.d/popdev-debug.list
    apt-get update
fi

# Update package definitions
if [ -n "${UPDATE}" ]
then
    apt-get update -y
fi

# Upgrade installed packages
if [ -n "${UPGRADE}" ]
then
    apt-get upgrade -y --allow-downgrades
fi

# Install packages
if [ -n "${INSTALL}" ]
then
    echo "Installing packages: ${INSTALL}"
    apt-get install -y ${INSTALL}
fi

if [ -n "${LANGUAGES}" ]
then
    pkgs=""
    for language in ${LANGUAGES}
    do
        echo "Adding language '$language'"
        pkgs+=" $(XDG_CURRENT_DESKTOP=GNOME check-language-support --show-installed --language="$language")"
    done
    if [ -n "$pkgs" ]
    then
        apt-get install -y --no-install-recommends $pkgs
    fi
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
        apt-get download ${MAIN_POOL}
    popd
fi

# Download restricted pool packages
if [ -n "${RESTRICTED_POOL}" ]
then
    mkdir -p "/iso/pool/restricted"
    chown -R _apt "/iso/pool/restricted"
    pushd "/iso/pool/restricted"
        apt-get download ${RESTRICTED_POOL}
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
