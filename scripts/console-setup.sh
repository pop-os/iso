#!/bin/sh

set -e -x

cat > /etc/default/console-setup <<EOF
# CONFIGURATION FILE FOR SETUPCON

# Consult the console-setup(5) manual page.

ACTIVE_CONSOLES="/dev/tty[1-6]"

CHARMAP="UTF-8"

CODESET="guess"
FONTFACE="Terminus"
FONTSIZE="16x32"

VIDEOMODE=

# The following is an example how to use a braille font
# FONT='lat9w-08.psf.gz brl-8x8.psf'
EOF

dpkg-reconfigure --frontend=noninteractive console-setup
