# Containerfile for reproducible Pop!_OS ZFS ISO builds
# Based on Ubuntu 24.04 (Noble Numbat)

FROM ubuntu:24.04

# Set environment for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Metadata
LABEL org.opencontainers.image.title="Pop!_OS ZFS ISO Builder"
LABEL org.opencontainers.image.description="Reproducible build environment for Pop!_OS with ZFS support"
LABEL org.opencontainers.image.version="24.04"
LABEL org.opencontainers.image.source="https://github.com/chainofreasoning/pop-os-iso-with-zfs"

# Set reproducible build timestamp (can be overridden at build time)
ARG SOURCE_DATE_EPOCH=1704067200
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}

# Update package lists and install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    make \
    # GPG for signing
    gnupg \
    gpg \
    # ISO building tools
    debootstrap \
    germinate \
    isolinux \
    mtools \
    ovmf \
    qemu-efi \
    qemu-kvm \
    qemu-user-static \
    squashfs-tools \
    xorriso \
    zsync \
    # GRUB and boot tools
    grub-efi-amd64-signed \
    grub-pc-bin \
    efibootmgr \
    # ZFS utilities (for build system, not installed in ISO)
    zfsutils-linux \
    # Additional utilities
    ca-certificates \
    curl \
    git \
    wget \
    software-properties-common \
    sudo \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Import Pop!_OS signing key
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 204DD8AEC33A7AFF

# Create build user (optional, for non-root builds)
RUN useradd -m -G sudo -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set working directory
WORKDIR /build

# Copy repository files (when building with context)
# COPY . /build/

# Default command
CMD ["/bin/bash"]

# Build instructions:
# 
# Build the container:
#   docker build -t pop-iso-builder -f Containerfile .
#   or
#   podman build -t pop-iso-builder -f Containerfile .
#
# Run the container to build ISO:
#   docker run --rm --privileged \
#     -v $(pwd):/build \
#     -w /build \
#     pop-iso-builder \
#     make DISTRO_VERSION=24.04 iso
#
# For reproducible builds, set SOURCE_DATE_EPOCH:
#   docker build --build-arg SOURCE_DATE_EPOCH=$(git log -1 --format=%ct) \
#     -t pop-iso-builder -f Containerfile .
#
# Interactive container for development:
#   docker run --rm -it --privileged \
#     -v $(pwd):/build \
#     pop-iso-builder \
#     /bin/bash
