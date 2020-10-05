#!/usr/bin/env bash

# Creates a .sources with the specified lines
# The first argument should be the filename, ending in ".sources"
# Subsequent arguments should be the required lines.

set -e -x

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# Set up sources file
echo "Creating ${FILENAME} sources file"
echo "X-Repolib-Name: ${NAME}" > ${FILENAME}
echo "Enabled: yes" >> ${FILENAME}
echo "Types: ${TYPES}" >> ${FILENAME}
echo "URIs: ${URIS}" >> ${FILENAME}
echo "Suites: ${SUITES}" >> ${FILENAME}
echo "Components: ${COMPONENTS}" >> ${FILENAME}
