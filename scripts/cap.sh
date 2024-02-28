#!/bin/bash

set -exuo pipefail

# Add more Capgemini specific dependencies.
# Mostly, build dependencies of chosen tools and environments, that we need to
# (or choose to) build from source, rather than use previously built package.
# For example, U-BOOT.
DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends \
    bison \
    flex \
    meson \
    # end of list

# Clean up.
apt-get clean autoclean
apt-get autoremove --purge --yes 
