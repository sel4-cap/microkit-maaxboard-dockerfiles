#!/bin/bash

set -exuo pipefail

#========================================
# The sel4 foundation microkit.
#========================================

# Build location.
mkdir -p "/tmp/build"

# Acquire seL4.
cd "/tmp/build"
git clone --branch "microkit" "git@github.com:seL4/seL4.git" sel4
cd "/tmp/build/sel4"
git reset --hard "7008430d4432c71a74b2a1da0afae58f7a8658df"

# Acquire microkit.
cd "/tmp/build"
git clone --branch "main" "git@github.com:seL4/microkit.git" microkit
cd "/tmp/build/microkit"
git reset --hard "e04afe55ac7f3d4242145fd7466b583fe1b1fce3"

# Achieve Python requirements.
cd "/tmp/build"
python3.9 -m venv "pyenv"
"/tmp/build/pyenv/bin/pip" install --upgrade pip setuptools wheel
"/tmp/build/pyenv/bin/pip" install -r "/tmp/build/microkit/requirements.txt"

# Build.
cd "/tmp/build/microkit"
export PATH="/util/sel4_foundation_arm_toolchain_baseline/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin:${PATH}"
"/tmp/build/pyenv/bin/python" build_sdk.py --sel4="/tmp/build/sel4"

# Retain built release.
mkdir -p "/util/microkit/sel4_foundation"
mv "/tmp/build/microkit/release" "/util/microkit/sel4_foundation/release"
chmod a+x "/util/microkit/sel4_foundation/release/microkit-sdk-1.2.6/bin/microkit"

# Discard build area.
rm -rf "/tmp/build"
