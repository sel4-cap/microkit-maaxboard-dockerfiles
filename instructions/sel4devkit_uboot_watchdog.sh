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

# Step 1:

# Acquire maaxboard-uboot.
cd "${BUILD_PATH}"
git clone --branch "main" "git@github.com:sel4devkit/maaxboard-uboot.git" maaxboard-uboot

# Clone.
cd "${BUILD_PATH}/maaxboard-uboot"
./clone.sh

# Pre-Unpack the firmware.
cd "${BUILD_PATH}/maaxboard-uboot/firmware"
bash firmware-imx-8.14.bin --auto-accept

# Build.
cd "${BUILD_PATH}/maaxboard-uboot"
./build-offline.sh

# Step 2:
# The Watchdog build is not completely successful. However, we only need a few
# components to assemble our desired U-Boot. We implicitly use some of the
# build residue from above to permit the Watchdog build. This is not ideal.

# Patch in Watchdog.
cd "${BUILD_PATH}/maaxboard-uboot"
echo "CONFIG_IMX_WATCHDOG=y" >> "uboot-imx/configs/maaxboard_defconfig"

# Build.
cd "${BUILD_PATH}/maaxboard-uboot"
./build-offline.sh

# Retain.
mkdir -p "${PACKAGE_PATH}/uboot/sel4devkit_uboot_watchdog"
cp -r "${BUILD_PATH}/maaxboard-uboot/flash.bin" "${PACKAGE_PATH}/uboot/sel4devkit_uboot_watchdog/flash.bin"
