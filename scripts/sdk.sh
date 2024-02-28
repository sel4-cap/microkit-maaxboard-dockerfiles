#!/bin/bash

set -exuo pipefail

#========================================
# Follow Instructions to make Packages.
#========================================
BUILD_PATH="/tmp/build"
PACKAGE_PATH="/packages"
LOG_PATH_FILE="/tmp/instructions.log.txt"

:> "${LOG_PATH_FILE}"
for INSTRUCTION in $(ls -1 /tmp/instructions/*.sh)
do
    echo "##################################################" >> "${LOG_PATH_FILE}"
    echo "${INSTRUCTION}"                                     >> "${LOG_PATH_FILE}"
    echo "##################################################" >> "${LOG_PATH_FILE}"
    "./${INSTRUCTION}" "${BUILD_PATH}" "${PACKAGE_PATH}"      >> "${LOG_PATH_FILE}"
    rm -rf "$BUILD_PATH"
done
