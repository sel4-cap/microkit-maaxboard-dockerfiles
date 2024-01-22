#!/bin/bash

set -exuo pipefail

# Source common functions.
source "/tmp/utils/common.sh"

# Extras for the MaaXBoard build environment, e.g. to build u-boot
as_root apt-get install -y --no-install-recommends \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    gcc-arm-linux-gnueabi \
    g++-arm-linux-gnueabi \
    sudo \
    cowsay \
    bison \
    flex \
    python-dev \
    # end of list

## Remove tools and architectures not required by the MaaXBoard. This
## reduces the size of the resulting Docker image.
#as_root apt-get remove -y \
#    gcc-riscv64-unknown-elf \
#    # end of list

# # Install required python2 dependencies.
# as_root wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
# as_root python2 get-pip.py 
# as_root rm get-pip.py
# as_root python2 -m pip install --no-cache-dir \
#     setuptools \
#     pylint \
#     sel4-deps \
#     camkes-deps \
#     # end of list

# # Checkout cached versions of seL4 build artefacts and set up environment
# # variable to use them.
# as_root mkdir $HOME_DIR/.sel4_cache
# as_root git clone https://github.com/sel4devkit/sel4_cached_artefacts $HOME_DIR/.sel4_cache
# as_root chown -R $USERNAME:sudo $HOME_DIR/.sel4_cache
# echo "export SEL4_CACHE_DIR=$HOME_DIR/.sel4_cache" >> "$HOME_DIR/.bashrc"
