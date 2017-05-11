# System76 Distribution

This is a spin of Ubuntu-GNOME with the System76 theme and drivers.

## Sources

The ISO contains a few changes, controlled by `scripts/build.sh` and `scripts/chroot.sh`. The following packages are installed:

- [system76-default-settings](https://launchpad.net/system76-default-settings) - sets the boot logo, login screen logo, default gsettings, and installs system76-pop-theme
- [system76-pop-theme](https://github.com/system76/pop-theme) - metapackage installing system76-pop-fonts, system76-pop-gtk-theme, and system76-pop-icon-theme
- [system76-pop-fonts](https://github.com/system76/pop-fonts) - contains packaged Fira and Roboto for use in the Pop theme
- [system76-pop-gtk-theme](https://github.com/system76/pop-gtk-theme) - contains the Pop GTK theme
- [system76-pop-icon-theme](https://github.com/system76/pop-icon-theme) - contains the Pop Icon theme

## Building

The build is controlled by the Makefile. The following commands can be used:
- `make` - Build an ISO at `build/system76.iso`
- `make run` - Run the ISO in BIOS mode
- `make uefi` - Run the ISO in UEFI mode
- `make clean` - Remove the ISO

To rebuild the ISO when you have made changes, you can use `make clean && make`
