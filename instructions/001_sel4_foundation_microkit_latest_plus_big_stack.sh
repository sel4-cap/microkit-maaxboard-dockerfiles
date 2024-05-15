#!/bin/bash

#========================================
# Instructions
#----------------------------------------
# The sel4 foundation Microkit.
# Latest revision. At point of build.
#========================================
set -exuo pipefail
BUILD_PATH=$(realpath "$1")
PACKAGE_PATH=$(realpath "$2")
mkdir -p "${BUILD_PATH}"
mkdir -p "${PACKAGE_PATH}"
#========================================

# Acquire seL4.
cd "${BUILD_PATH}"
git clone --branch "microkit" "git@github.com:seL4/seL4.git" sel4
cd "${BUILD_PATH}/sel4"
git reset --hard "7008430d4432c71a74b2a1da0afae58f7a8658df"

# Acquire microkit.
cd "${BUILD_PATH}"
git clone --branch "main" "git@github.com:seL4/microkit.git" microkit
cd "${BUILD_PATH}/microkit"

# Increase Stack Patch.
cd "${BUILD_PATH}/microkit"
sed -i libmicrokit/src/crt0.s -e 's/0xff0/0xFFFE/g' # 65536-2 = 0xFFFE
sed -i libmicrokit/src/main.c -e 's/_stack\[4096\]/_stack[65536]/g'
git diff

# Achieve Python requirements.
cd "${BUILD_PATH}"
python -m venv "pyenv"
"${BUILD_PATH}/pyenv/bin/pip" install --upgrade pip setuptools wheel
"${BUILD_PATH}/pyenv/bin/pip" install -r "${BUILD_PATH}/microkit/requirements.txt"

# By default, microkit builds for all targets, which imposes greater compiler
# dependencies than we wish. Currently, this is awkward to deactivate (on this
# variant of Microkit), and appears to function for us. In due course,
# probally add: --filter-boards "maaxboard"

# Build.
cd "${BUILD_PATH}/microkit"
export PATH="/util/sel4_foundation_arm_toolchain_baseline/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin:${PATH}"
"${BUILD_PATH}/pyenv/bin/python" build_sdk.py --sel4="${BUILD_PATH}/sel4" 

# Ensure the built binary has execute for all.
# The sel4 build scripts do not ensure this, when building as root.
chmod a+x "${BUILD_PATH}/microkit/release/microkit-sdk-1.2.6/bin/microkit"

# Build Maaxboard hello example.
cd "${BUILD_PATH}/microkit/release/microkit-sdk-1.2.6/board/maaxboard/example/hello"
mkdir -p "built"
make BUILD_DIR="built" MICROKIT_SDK="${BUILD_PATH}/microkit/release/microkit-sdk-1.2.6" MICROKIT_BOARD="maaxboard" MICROKIT_CONFIG="debug"

# Retain built release.
mkdir -p "${PACKAGE_PATH}/microkit/sel4_foundation_microkit_latest_plus_big_stack"
cp -r "${BUILD_PATH}/microkit/release" "${PACKAGE_PATH}/microkit/sel4_foundation_microkit_latest_plus_big_stack/release"
