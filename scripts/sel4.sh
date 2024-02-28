#!/bin/bash

set -exuo pipefail

# Add additional architectures for cross-compiled libraries.
dpkg --add-architecture armhf
dpkg --add-architecture armel

# Install the tools required to build all aspects of the sel4 toolchain which
# we currently do, or credibally might, make use of.
DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends \
    astyle=3.1-2+b1 \
    build-essential \
    ccache \
    clang-11 \
    cmake \
    cmake-curses-gui \
    cpio \
    device-tree-compiler \
    doxygen \
    g++-10 \
    g++-10-aarch64-linux-gnu \
    g++-10-arm-linux-gnueabi \
    g++-10-arm-linux-gnueabihf \
    gcc-10 \
    gcc-10-aarch64-linux-gnu \
    gcc-10-arm-linux-gnueabi \
    gcc-10-arm-linux-gnueabihf \
    gcc-10-base \
    gcc-10-multilib \
    libarchive-dev \
    libcc1-0 \
    libclang-11-dev \
    libncurses-dev \
    libuv1 \
    libxml2-utils \
    musl-tools=1.2.2-1 \
    ninja-build \
    pandoc \
    protobuf-compiler \
    qemu-system-arm \
    qemu-system-misc \
    qemu-system-x86 \
    sloccount \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-latex-recommended \
    u-boot-tools \
    # end of list

# We largely wish to use compilers at version 10, hence the selection above.
# However, since we picked a version (x-10), rather than the default (x), only
# the versioned command (x-10) is made available. To resolve, map the default
# (x) to the versioned command (x-10). This is done very manually here, for
# visibility of what is being (and not being) done.

# Package: g++-10
update-alternatives --install /usr/bin/g++                            g++                               /usr/bin/g++-10                            555
update-alternatives --install /usr/bin/x86_64-linux-gnu-g++           x86_64-linux-gnu-g++              /usr/bin/x86_64-linux-gnu-g++-10           555
# Package: g++-10-aarch64-linux-gnu                                                                                                              
update-alternatives --install /usr/bin/aarch64-linux-gnu-g++          aarch64-linux-gnu-g++             /usr/bin/aarch64-linux-gnu-g++-10          555
# Package: g++-10-arm-linux-gnueabi                                                                                                              
update-alternatives --install /usr/bin/arm-linux-gnueabi-g++          arm-linux-gnueabi-g++             /usr/bin/arm-linux-gnueabi-g++-10          555
# Package: g++-10-arm-linux-gnueabihf                                                                                                            
update-alternatives --install /usr/bin/arm-linux-gnueabihf-g++        arm-linux-gnueabihf-g++           /usr/bin/arm-linux-gnueabihf-g++-10        555
# Package: gcc-10                                                                                                                                
update-alternatives --install /usr/bin/gcc                            gcc                               /usr/bin/gcc-10                            555
update-alternatives --install /usr/bin/gcc-ar                         gcc-ar                            /usr/bin/gcc-ar-10                         555
update-alternatives --install /usr/bin/gcc-nm                         gcc-nm                            /usr/bin/gcc-nm-10                         555
update-alternatives --install /usr/bin/gcc-ranlib                     gcc-ranlib                        /usr/bin/gcc-ranlib-10                     555
update-alternatives --install /usr/bin/gcov                           gcov                              /usr/bin/gcov-10                           555
update-alternatives --install /usr/bin/gcov-dump                      gcov-dump                         /usr/bin/gcov-dump-10                      555
update-alternatives --install /usr/bin/gcov-tool                      gcov-tool                         /usr/bin/gcov-tool-10                      555
update-alternatives --install /usr/bin/lto-dump                       lto-dump                          /usr/bin/lto-dump-10                       555
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc           x86_64-linux-gnu-gcc              /usr/bin/x86_64-linux-gnu-gcc-10           555
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ar        x86_64-linux-gnu-gcc-ar           /usr/bin/x86_64-linux-gnu-gcc-ar-10        555
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-nm        x86_64-linux-gnu-gcc-nm           /usr/bin/x86_64-linux-gnu-gcc-nm-10        555
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcc-ranlib    x86_64-linux-gnu-gcc-ranlib       /usr/bin/x86_64-linux-gnu-gcc-ranlib-10    555
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcov          x86_64-linux-gnu-gcov             /usr/bin/x86_64-linux-gnu-gcov-10          555
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcov-dump     x86_64-linux-gnu-gcov-dump        /usr/bin/x86_64-linux-gnu-gcov-dump-10     555
update-alternatives --install /usr/bin/x86_64-linux-gnu-gcov-tool     x86_64-linux-gnu-gcov-tool        /usr/bin/x86_64-linux-gnu-gcov-tool-10     555
update-alternatives --install /usr/bin/x86_64-linux-gnu-lto-dump      x86_64-linux-gnu-lto-dump         /usr/bin/x86_64-linux-gnu-lto-dump-10      555
# Package: gcc-10-aarch64-linux-gnu                                                                                                              
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc          aarch64-linux-gnu-gcc             /usr/bin/aarch64-linux-gnu-gcc-10          555
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc-ar       aarch64-linux-gnu-gcc-ar          /usr/bin/aarch64-linux-gnu-gcc-ar-10       555
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc-nm       aarch64-linux-gnu-gcc-nm          /usr/bin/aarch64-linux-gnu-gcc-nm-10       555
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc-ranlib   aarch64-linux-gnu-gcc-ranlib      /usr/bin/aarch64-linux-gnu-gcc-ranlib-10   555
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcov         aarch64-linux-gnu-gcov            /usr/bin/aarch64-linux-gnu-gcov-10         555
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcov-dump    aarch64-linux-gnu-gcov-dump       /usr/bin/aarch64-linux-gnu-gcov-dump-10    555
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcov-tool    aarch64-linux-gnu-gcov-tool       /usr/bin/aarch64-linux-gnu-gcov-tool-10    555
update-alternatives --install /usr/bin/aarch64-linux-gnu-lto-dump     aarch64-linux-gnu-lto-dump        /usr/bin/aarch64-linux-gnu-lto-dump-10     555
# Package: gcc-10-arm-linux-gnueabi                                                                                                              
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc          arm-linux-gnueabi-gcc             /usr/bin/arm-linux-gnueabi-gcc-10          555
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc-ar       arm-linux-gnueabi-gcc-ar          /usr/bin/arm-linux-gnueabi-gcc-ar-10       555
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc-nm       arm-linux-gnueabi-gcc-nm          /usr/bin/arm-linux-gnueabi-gcc-nm-10       555
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc-ranlib   arm-linux-gnueabi-gcc-ranlib      /usr/bin/arm-linux-gnueabi-gcc-ranlib-10   555
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcov         arm-linux-gnueabi-gcov            /usr/bin/arm-linux-gnueabi-gcov-10         555
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcov-dump    arm-linux-gnueabi-gcov-dump       /usr/bin/arm-linux-gnueabi-gcov-dump-10    555
update-alternatives --install /usr/bin/arm-linux-gnueabi-gcov-tool    arm-linux-gnueabi-gcov-tool       /usr/bin/arm-linux-gnueabi-gcov-tool-10    555
update-alternatives --install /usr/bin/arm-linux-gnueabi-lto-dump     arm-linux-gnueabi-lto-dump        /usr/bin/arm-linux-gnueabi-lto-dump-10     555
# Package: gcc-10-arm-linux-gnueabihf                                                                                                            
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcc        arm-linux-gnueabihf-gcc           /usr/bin/arm-linux-gnueabihf-gcc-10        555
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcc-ar     arm-linux-gnueabihf-gcc-ar        /usr/bin/arm-linux-gnueabihf-gcc-ar-10     555
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcc-nm     arm-linux-gnueabihf-gcc-nm        /usr/bin/arm-linux-gnueabihf-gcc-nm-10     555
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcc-ranlib arm-linux-gnueabihf-gcc-ranlib    /usr/bin/arm-linux-gnueabihf-gcc-ranlib-10 555
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcov       arm-linux-gnueabihf-gcov          /usr/bin/arm-linux-gnueabihf-gcov-10       555
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcov-dump  arm-linux-gnueabihf-gcov-dump     /usr/bin/arm-linux-gnueabihf-gcov-dump-10  555
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcov-tool  arm-linux-gnueabihf-gcov-tool     /usr/bin/arm-linux-gnueabihf-gcov-tool-10  555
update-alternatives --install /usr/bin/arm-linux-gnueabihf-lto-dump   arm-linux-gnueabihf-lto-dump      /usr/bin/arm-linux-gnueabihf-lto-dump-10   555
update-alternatives --install /usr/bin/asan_symbolize                 asan_symbolize                    /usr/bin/asan_symbolize-11                 555
# Package: clang-11                                                                                                                              
update-alternatives --install /usr/bin/clang++                        clang++                           /usr/bin/clang++-11                        555
update-alternatives --install /usr/bin/clang                          clang                             /usr/bin/clang-11                          555
update-alternatives --install /usr/bin/clang-cpp                      clang-cpp                         /usr/bin/clang-cpp-11                      555

# Skeleton for utility material.
mkdir -p "/util"
mkdir -p "/util/sel4_foundation_arm_toolchain_baseline"

# Provide the sel4 foundation select arm toolchain baseline compiler.
cd "/util/sel4_foundation_arm_toolchain_baseline"
curl --output "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz" "https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"
tar -xf "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"
rm -f "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"

# Clean up.
apt-get clean autoclean
apt-get autoremove --purge --yes 
