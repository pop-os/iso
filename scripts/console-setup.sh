#!/bin/sh

set -e -x

FONTFACE="Terminus"
FONTSIZE="16x32"

# Source debconf library.
. /usr/share/debconf/confmodule

db_set console-setup/fontface47 "${FONTFACE}"
db_set console-setup/fontsize "${FONTSIZE}"
db_set console-setup/fontsize-fb47 "${FONTSIZE} (framebuffer only)"
db_set console-setup/fontsize-text47 "${FONTSIZE} (framebuffer only)"

db_stop

cat > /etc/default/console-setup <<EOF
# CONFIGURATION FILE FOR SETUPCON

# Consult the console-setup(5) manual page.

ACTIVE_CONSOLES="/dev/tty[1-6]"

CHARMAP="UTF-8"

CODESET="guess"
FONTFACE="${FONTFACE}"
FONTSIZE="${FONTSIZE}"

VIDEOMODE=

# The following is an example how to use a braille font
# FONT='lat9w-08.psf.gz brl-8x8.psf'
EOF

update-initramfs -u
