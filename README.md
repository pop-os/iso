# Pop!\_OS ISO production

This repository contains the tools necessary for building Pop!\_OS ISOs.

## Requirements

First you need to import the Pop!\_OS ISO signing key:

```sh
gpg --recv-keys 204DD8AEC33A7AFF
```

Then you need to generate your own GPG key and upload it to a keyserver:

```sh
gpg --full-gen-key
gpg --send-keys --keyserver keyserver.ubuntu.com ${YOUR_KEY_ID_HERE}
```

While you are waiting for your key to be uploaded, install the dependencies:

```sh
./deps.sh
```

## Building

The build is controlled by the Makefile. The following commands can be used:
- `make` - Build an ISO at `build/17.10/pop-os.iso`
- `make qemu_bios` - Run the ISO in BIOS mode
- `make qemu_uefi` - Run the ISO in UEFI mode
- `make clean` - Remove the build files, keeping the debootstrap
- `make distclean` - Remove the debootstrap and other build files

The configuration can be changed in `mk/config.mk`.

To rebuild the ISO when you have made changes, you can use `make clean && make`
