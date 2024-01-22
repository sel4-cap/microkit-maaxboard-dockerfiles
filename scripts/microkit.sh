#!/bin/bash

set -exuo pipefail

# Source common functions.
source "/tmp/utils/common.sh"

# Skeleton for common user material.
try_nonroot_first mkdir -p "/util" || chown_dir_to_user "/util"
try_nonroot_first mkdir -p "/util/microkit" || chown_dir_to_user "/util/microkit"

# Extras for microkit build.
as_root apt-get install -y --no-install-recommends \
    pandoc \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    texlive-latex-extra \
    musl-tools=1.2.2-1 \
    python3.9 \
    python3.9-venv \
    # end of list


#
# Meh, this does not fit nicely. Where is the line between base config / and builds within that...
#


# # Temp area to build.
# export BUILD_DIR="/tmp/microkit"
# try_nonroot_first mkdir -p "$BUILD_DIR" || chown_dir_to_user "$BUILD_DIR"
# 
# # Match sel4 foundation in building against a specific compiler.
# cd "$BUILD_DIR"
# curl --output "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz" "https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"
# tar -xf "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"
# export PATH="$BUILD_DIR/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin:${PATH}"
# 
# #========================================
# # Forks.
# #========================================
# 
# # The capgemini base build of microkit.
# #
# # Going forward, once microkit supports our boards, we may build from the
# # master source (sel4 foundation). Alternatively, if this proves onerous,
# # perhaps build from master source (sel4 foundation) plus our defined changes
# # (captured as pull requests).
# 
# export TARGET_DIR="/util/microkit"
# export BUILD_DIR="${BUILD_DIR}"
# export LABEL="cap_base"
# export SEL4_REPO="git@github.com:seL4/seL4.git"
# export SEL4_BRANCH="microkit"
# export SEL4_COMMIT="92f0f3ab28f00c97851512216c855f4180534a60"
# export MICROKIT_REPO="git@github.com:sel4-cap/microkit.git"
# export MICROKIT_BRANCH="maaxboard-support"
# export MICROKIT_COMMIT=""
# 
# /bin/bash "/tmp/utils/add_microkit.sh"
# 
# 


#========================================
# Tidy.
#========================================

# Remove bits that are likely no longer needed.
#rm -rf "$BUILD_DIR"

#as_root apt-get remove -y \
#    pandoc \
#    texlive-latex-base \
#    texlive-fonts-recommended \
#    texlive-latex-recommended \
#    texlive-latex-extra \
#    # end of list
#
#
#possibly_toggle_apt_snapshot
