# Pop!\_OS

Pop!\_OS is designed for people who use their computer to create; whether it’s complicated, professional grade software and products, sophisticated 3D models, computer science in academia, or makers working on their latest invention. The Pop! user interface stays out of the way while offering extensive customization to perfect your work flow. Built on Ubuntu, you have access to vast repositories of open source software and development tools.

Pop!\_OS’s first release was on October 19th, 2017. For more information, [visit the Pop!\_OS website](https://pop.system76.com) and [view the Pop!\_OS documentation](http://pop.system76.com/docs/)

## Sources

The ISO contains a few changes, controlled by the configuration in `mk/config.mk`. Pop!\_OS packages are hosted [on Launchpad](https://launchpad.net/~system76/+archive/ubuntu/pop/+packages). Many Pop!\_OS packages have source on Github, under the [System76 organization](https://github.com/system76).

## Building

The build is controlled by the Makefile. The following commands can be used:
- `make` - Build an ISO at `build/17.10/pop-os.iso`
- `make qemu_bios` - Run the ISO in BIOS mode
- `make qemu_uefi` - Run the ISO in UEFI mode
- `make clean` - Remove the build files, keeping the debootstrap
- `make distclean` - Remove the debootstrap and other build files

To rebuild the ISO when you have made changes, you can use `make clean && make`
