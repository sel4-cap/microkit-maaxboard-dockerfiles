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

# Choose the latest of all dependencies. Mileage may vary.

# Acquire seL4.
cd "${BUILD_PATH}"
git clone --branch "microkit-dev" "git@github.com:Ivan-Velickovic/seL4.git" sel4

# Acquire microkit.
cd "${BUILD_PATH}"
git clone --branch "dev" "git@github.com:Ivan-Velickovic/microkit.git" microkit
cd "${BUILD_PATH}/microkit"


# We amend the stack-hack-patch for Ivan's forked Microkit, which has a
# different layout. We only patch for aarch64 (our target).

# Increase Stack Patch.
cd "${BUILD_PATH}/microkit"
sed -i libmicrokit/src/aarch64/crt0.s -e 's/0xff0/0x1FFFE/g' # 131072-2 = 131070 = 0x1FFFE
sed -i libmicrokit/src/main.c -e 's/_stack\[4096\]/_stack[131072]/g'
git diff

# Achieve Python requirements.
cd "${BUILD_PATH}"
python -m venv "pyenv"
"${BUILD_PATH}/pyenv/bin/pip" install --upgrade pip setuptools wheel
"${BUILD_PATH}/pyenv/bin/pip" install -r "${BUILD_PATH}/microkit/requirements.txt"

# By default, microkit builds for all targets, which imposes greater compiler
# dependencies than we wish. Pick maaxboard, only.

# Build.
cd "${BUILD_PATH}/microkit"
export PATH="/util/sel4_foundation_arm_toolchain_baseline/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin:${PATH}"
"${BUILD_PATH}/pyenv/bin/python" build_sdk.py --sel4="${BUILD_PATH}/sel4" --filter-boards "maaxboard"

# Ensure the built binary has execute for all.
# The sel4 build scripts do not ensure this, when building as root.
chmod a+x "${BUILD_PATH}/microkit/release/microkit-sdk-1.2.6/bin/microkit"

# Build Maaxboard hello example.
cd "${BUILD_PATH}/microkit/release/microkit-sdk-1.2.6/board/maaxboard/example/hello"
mkdir -p "built"
make BUILD_DIR="built" MICROKIT_SDK="${BUILD_PATH}/microkit/release/microkit-sdk-1.2.6" MICROKIT_BOARD="maaxboard" MICROKIT_CONFIG="debug"

# Retain built release.
mkdir -p "${PACKAGE_PATH}/microkit/auts_microkit_latest_plus_big_stack"
cp -r "${BUILD_PATH}/microkit/release" "${PACKAGE_PATH}/microkit/auts_microkit_latest_plus_big_stack/release"
