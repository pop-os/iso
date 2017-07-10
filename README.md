# Pop!\_OS

Pop!\_OS is designed for people who use their computer to create; whether it’s complicated, professional grade software and products, sophisticated 3D models, computer science in academia, or makers working on their latest invention. The Pop! user interface stays out of the way while offering extensive customization to perfect your work flow. Built on Ubuntu, you have access to vast repositories of open source software and development tools.

Pop!\_OS’s first release is October 19, 2017

## Sources

The ISO contains a few changes, controlled by bash scripts in the `scripts` directory. The following packages are installed:

- [pop-default-settings](https://github.com/system76/pop-default-settings) - sets the boot logo, login screen logo, default gsettings, and installs system76-pop-theme
- [pop-theme](https://github.com/system76/pop-theme) - metapackage installing pop-fonts, pop-gtk-theme, and pop-icon-theme
- [pop-fonts](https://github.com/system76/pop-fonts) - contains packaged Fira and Roboto for use in the Pop theme
- [pop-gtk-theme](https://github.com/system76/pop-gtk-theme) - contains the Pop GTK theme
- [pop-icon-theme](https://github.com/system76/pop-icon-theme) - contains the Pop Icon theme

## Building

The build is controlled by the Makefile. The following commands can be used:
- `make` - Build an ISO at `build/pop-os.iso`
- `make qemu` - Run the ISO in BIOS mode
- `make qemu_uefi` - Run the ISO in UEFI mode
- `make clean` - Remove the ISO

To rebuild the ISO when you have made changes, you can use `make clean && make`
