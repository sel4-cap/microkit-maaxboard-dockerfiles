#!/bin/bash

set -exuo pipefail


# BJE: Hmm. Is this needed?
# What is the goal platform here: Microkit? UBOOT? Maaxboard? Really, it's the
# bits and bobs we use to develop, and a camkes context is historically
# slightly assumed. Too much is likely less annoying, than too little. It
# seems possible to incrementally pick away at the stack, and sharpen those
# dependencies. 
# BJE: Hmm. Is this needed?

# Get dependencies.
dpkg --add-architecture i386
apt-get update -q
apt-get install -y --no-install-recommends \
    acl \
    fakeroot \
    linux-libc-dev-i386-cross \
    linux-libc-dev:i386 \
    pkg-config \
    spin \
    lib32stdc++-10-dev \
    # end of list

# Required for testing.
apt-get install -y --no-install-recommends \
    gdb \
    libssl-dev \
    libcunit1-dev \
    libglib2.0-dev \
    libsqlite3-dev \
    libgmp3-dev \
    # end of list

# Required for stack to use tcp properly.
apt-get install -y --no-install-recommends \
    netbase \
    # end of list

# Required for rumprun.
apt-get install -y --no-install-recommends \
    dh-autoreconf \
    genisoimage \
    gettext \
    rsync \
    xxd \
    # end of list

# Get python deps for CAmkES.
pip3 install --no-cache-dir \
    camkes-deps \
    nose \
    # end of list
