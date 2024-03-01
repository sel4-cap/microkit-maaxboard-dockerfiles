#!/bin/bash

#========================================
# Instructions
#----------------------------------------
# sel4devkit uboot.
# Latest revision. At point of build.
#========================================
set -exuo pipefail
BUILD_PATH=$(realpath "$1")
PACKAGE_PATH=$(realpath "$2")
mkdir -p "${BUILD_PATH}"
mkdir -p "${PACKAGE_PATH}"
#========================================

# Acquire maaxboard-uboot.
cd "${BUILD_PATH}"
git clone --branch "main" "git@github.com:sel4devkit/maaxboard-uboot.git" maaxboard-uboot

# Clone.
cd "${BUILD_PATH}"
cd "maaxboard-uboot"
./clone.sh

# Pre-Unpack the firmware.
cd "${BUILD_PATH}"
cd "maaxboard-uboot"
cd "firmware"
bash firmware-imx-8.14.bin --auto-accept

# Build.
cd "${BUILD_PATH}"
cd "maaxboard-uboot"
./build-offline.sh

# Retain.
mkdir -p "${PACKAGE_PATH}/uboot/sel4devkit_uboot"
cp -r "${BUILD_PATH}/maaxboard-uboot/flash.bin" "${PACKAGE_PATH}/uboot/sel4devkit_uboot/flash.bin"
