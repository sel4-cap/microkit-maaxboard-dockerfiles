#!/bin/bash

set -exuo pipefail

# Source common functions.
source "/tmp/utils/common.sh"

# Get dependencies
as_root dpkg --add-architecture i386
as_root apt-get update -q
as_root apt-get install -y --no-install-recommends \
    acl \
    fakeroot \
    linux-libc-dev-i386-cross \
    linux-libc-dev:i386 \
    pkg-config \
    spin \
    lib32stdc++-10-dev \
    # end of list

# Required for testing
as_root apt-get install -y --no-install-recommends \
    gdb \
    libssl-dev \
    libcunit1-dev \
    libglib2.0-dev \
    libsqlite3-dev \
    libgmp3-dev \
    # end of list

# Required for stack to use tcp properly
as_root apt-get install -y --no-install-recommends \
    netbase \
    # end of list

# Required for rumprun
as_root apt-get install -y --no-install-recommends \
    dh-autoreconf \
    genisoimage \
    gettext \
    rsync \
    xxd \
    # end of list

# Get python deps for CAmkES
as_root pip3 install --no-cache-dir \
    camkes-deps \
    nose \
    # end of list
