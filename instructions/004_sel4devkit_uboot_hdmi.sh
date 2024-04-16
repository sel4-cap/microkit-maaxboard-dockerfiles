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
cd "${BUILD_PATH}/maaxboard-uboot"
./clone.sh

# Pre-Unpack the firmware.
cd "${BUILD_PATH}/maaxboard-uboot/firmware"
bash firmware-imx-8.14.bin --auto-accept

# Patch for HDMI.
cd "${BUILD_PATH}/maaxboard-uboot"
sed -i -e '/# Copy the binaries, firmware and device tree/a cp firmware/firmware-imx-8.14/firmware/hdmi/cadence/signed_hdmi_imx8m.bin imx-mkimage/iMX8M/signed_hdmi_imx8m.bin' -e 's/SOC=iMX8MQ flash_ddr4_val_no_hdmi/SOC=iMX8MQ flash_ddr4_val/g' build-offline.sh
git diff

# Build.
cd "${BUILD_PATH}/maaxboard-uboot"
./build-offline.sh

# Retain.
mkdir -p "${PACKAGE_PATH}/uboot/sel4devkit_uboot_hdmi"
cp -r "${BUILD_PATH}/maaxboard-uboot/flash.bin" "${PACKAGE_PATH}/uboot/sel4devkit_uboot_hdmi/flash.bin"
