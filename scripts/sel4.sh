#!/bin/bash

set -exuo pipefail

# Add additional architectures for cross-compiled libraries.
# Install the tools required to compile seL4.
dpkg --add-architecture armhf
dpkg --add-architecture armel
apt-get install -y --no-install-recommends \
    astyle=3.1-2+b1 \
    build-essential \
    ccache \
    cmake \
    cmake-curses-gui \
    coreutils \
    cpio \
    curl \
    device-tree-compiler \
    doxygen \
    libarchive-dev \
    libcc1-0 \
    libncurses-dev \
    libuv1 \
    libxml2-utils \
    ninja-build \
    protobuf-compiler \
    python3-protobuf \
    qemu-system-x86 \
    sloccount \
    u-boot-tools \
    clang-11 \
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
    gcc-riscv64-unknown-elf \
    libclang-11-dev \
    qemu-system-arm \
    qemu-system-misc \
    # end of list

# BJE: Hmm. What is all this really doing?
# Too much is likely less annoying, than too little. It seems possible to
# incrementally pick away at the stack, and sharpen those dependencies.

compiler_version=10

# Set default compiler to be gcc-$compiler_version using update-alternatives
# This is necessary particularly for the cross-compilers, which don't put
# a genericly named version of themselves in the PATH.
for compiler in gcc \
                g++ \
                # end of list
    do
    for file in $(dpkg-query -L ${compiler} | grep /usr/bin/); do
        name=$(basename "$file")
        echo "$name - $file"
        update-alternatives --install "$file" "$name" "$file-$compiler_version" 50 || :  # don't stress if it doesn't work
        update-alternatives --auto "$name" || :
    done
done

for compiler in gcc-${compiler_version}-arm-linux-gnueabi \
                cpp-${compiler_version}-arm-linux-gnueabi \
                g++-${compiler_version}-arm-linux-gnueabi \
                gcc-${compiler_version}-aarch64-linux-gnu \
                cpp-${compiler_version}-aarch64-linux-gnu \
                g++-${compiler_version}-aarch64-linux-gnu \
                gcc-${compiler_version}-arm-linux-gnueabihf \
                cpp-${compiler_version}-arm-linux-gnueabihf \
                g++-${compiler_version}-arm-linux-gnueabihf \
                # end of list
do
    echo ${compiler}
    for file in $(dpkg-query -L ${compiler} | grep /usr/bin/); do
        name=$(basename "$file" | sed "s/-${compiler_version}\$//g")
        # shellcheck disable=SC2001
        link=$(echo "$file" | sed "s/-${compiler_version}\$//g")
        echo "$name - $file"
        (
            update-alternatives --install "${link}" "${name}" "${file}" 60 && \
            update-alternatives --auto "${name}"
        ) || : # Don't worry if this fails
    done
done

# Ensure that clang-11 shows up as clang.
for compiler in clang \
                clang++ \
                # end of list
    do
        update-alternatives --install /usr/bin/"$compiler" "$compiler" "$(which "$compiler"-11)" 60 && \
        update-alternatives --auto "$compiler"
done
# Do a quick check to make sure it works:
clang --version

# Get seL4 python3 deps
# Pylint is for checking included python scripts
# Setuptools sometimes is a bit flaky, so double checking it is installed here
pip3 install --no-cache-dir \
    setuptools
pip3 install --no-cache-dir \
    pylint \
    sel4-deps \
    # end of list
