# Pop!\_OS

Pop!\_OS is designed for people who use their computer to create; whether it’s complicated, professional grade software and products, sophisticated 3D models, computer science in academia, or makers working on their latest invention. The Pop! user interface stays out of the way while offering extensive customization to perfect your work flow. Built on Ubuntu, you have access to vast repositories of open source software and development tools.

Pop!\_OS’s first release was on October 19th, 2017. For more information, [visit the Pop!\_OS website](https://system76.com/pop) and [view the Pop!\_OS documentation](http://pop.system76.com/docs/).

## Sources

Pop!\_OS packages are hosted [on Launchpad](https://launchpad.net/~system76/+archive/ubuntu/pop/+packages). Many Pop!\_OS packages have source on Github, under the [System76 organization](https://github.com/system76).

- [com.github.donadigo.eddy](https://github.com/system76/eddy)
- [gnome-shell-extension-alt-tab-raise-first-window](https://github.com/system76/gnome-shell-extension-alt-tab-raise-first-window)
- [gnome-shell-extension-always-show-workspaces](https://github.com/system76/gnome-shell-extension-always-show-workspaces)
- [gnome-shell-extension-pop-shop-details](https://github.com/system76/gnome-shell-extension-pop-shop-details)
- [gnome-shell-extension-pop-suspend-button](https://github.com/system76/gnome-shell-extension-suspend-button)
- [muff](https://github.com/system76/muff)
- [pop-default-settings](https://github.com/system76/pop-default-settings)
- [pop-desktop](https://github.com/system76/pop-desktop)
- [pop-fonts](https://github.com/system76/pop-fonts)
- [pop-gnome-control-center](https://github.com/system76/gnome-control-center)
- [pop-gnome-initial-setup](https://github.com/system76/gnome-initial-setup)
- [pop-grub-theme](https://github.com/system76/pop-grub-theme)
- [pop-gtk-theme](https://github.com/system76/pop-gtk-theme)
- [pop-icon-theme](https://github.com/system76/pop-icon-theme)
- [pop-plymouth-theme](https://github.com/system76/pop-plymouth-theme)
- [pop-session](https://github.com/system76/pop-session)
- [pop-shop](https://github.com/system76/pop-shop)
- [pop-theme](https://github.com/system76/pop-theme)
- [pop-wallpapers](https://github.com/system76/pop-wallpapers)
- [ubiquity-slideshow-pop](https://github.com/system76/ubiquity-slideshow-pop)

## Building

The build is controlled by the Makefile. The following commands can be used:
- `make` - Build an ISO at `build/17.10/pop-os.iso`
- `make qemu_bios` - Run the ISO in BIOS mode
- `make qemu_uefi` - Run the ISO in UEFI mode
- `make clean` - Remove the build files, keeping the debootstrap
- `make distclean` - Remove the debootstrap and other build files

The configuration can be changed in `mk/config.mk`. 

To rebuild the ISO when you have made changes, you can use `make clean && make`
