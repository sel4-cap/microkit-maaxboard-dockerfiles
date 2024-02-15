#!/bin/bash

set -exuo pipefail

# Skeleton for common user material.
mkdir -p "/util"
mkdir -p "/util/sel4_foundation_arm_toolchain_baseline"
mkdir -p "/util/microkit"

# Extras for microkit build.
apt-get install -y --no-install-recommends \
    pandoc \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    texlive-latex-extra \
    musl-tools=1.2.2-1 \
    python3.9 \
    python3.9-venv \
    # end of list

# Provide the sel4 foundation select arm toolchain baseline compiler.
cd "/util/sel4_foundation_arm_toolchain_baseline"
curl --output "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz" "https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"
tar -xf "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"
rm -f "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz"

# Choose not to build microkit here. These items are not stable. We have a
# final "sdk" layer, where a set of unstable items may be regurally added and
# changed as needs.
