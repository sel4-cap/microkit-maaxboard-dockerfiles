#!/bin/bash

#========================================
# Instructions
#========================================
set -exuo pipefail
BUILD_PATH=$(realpath "$1")
PACKAGE_PATH=$(realpath "$2")
mkdir -p "${BUILD_PATH}"
mkdir -p "${PACKAGE_PATH}"
#========================================
# Target:
#----------------------------------------
# The sel4 foundation Microkit.
# Latest revision. At point of build.
#========================================

# Acquire seL4.
cd "${BUILD_PATH}"
git clone --branch "microkit" "git@github.com:seL4/seL4.git" sel4
cd "${BUILD_PATH}/sel4"
git reset --hard "7008430d4432c71a74b2a1da0afae58f7a8658df"

# Acquire microkit.
cd "${BUILD_PATH}"
git clone --branch "main" "git@github.com:sel4-cap/microkit.git" microkit
cd "${BUILD_PATH}/microkit"

# Achieve Python requirements.
cd "${BUILD_PATH}"
python -m venv "pyenv"
"${BUILD_PATH}/pyenv/bin/pip" install --upgrade pip setuptools wheel
"${BUILD_PATH}/pyenv/bin/pip" install -r "${BUILD_PATH}/microkit/requirements.txt"

# Build.
cd "${BUILD_PATH}/microkit"
export PATH="/util/sel4_foundation_arm_toolchain_baseline/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin:${PATH}"
"${BUILD_PATH}/pyenv/bin/python" build_sdk.py --sel4="${BUILD_PATH}/sel4"

# Ensure the built binary has execute for all.
# The sel4 build scripts do not ensure this, when building as root.
chmod a+x "${BUILD_PATH}/microkit/release/microkit-sdk-1.2.6/bin/microkit"

# Retain built release.
mkdir -p "${PACKAGE_PATH}/microkit/cap_fork_microkit_increased_stack/"
cp -r "${BUILD_PATH}/microkit/release" "${PACKAGE_PATH}/microkit/cap_fork_microkit_increased_stack/release"
