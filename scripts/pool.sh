#!/usr/bin/env bash

set -e

for pool in "$@"
do
	pushd "${pool}"
	ls -1 | while read deb
    do
        # Replace URL encoding
		new_deb="${deb//%/x}"
        if [ "${deb}" != "${new_deb}" ]
        then
    		mv -v "${deb}" "${new_deb}"
        fi
	done
	popd
done
