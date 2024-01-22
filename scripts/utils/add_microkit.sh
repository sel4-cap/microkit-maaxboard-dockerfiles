#!/bin/bash
#
# This script adds and removes packages to control those required
# for building for the Avnet MaaxBoard. 
#
# SPDX-License-Identifier: BSD-2-Clause
#

set -exuo pipefail

# Source common functions.
source "/tmp/utils/common.sh"

# Clean area to build.
export LABEL_BUILD_DIR="${BUILD_DIR}/${LABEL}"
try_nonroot_first mkdir -p "$LABEL_BUILD_DIR" || chown_dir_to_user "$LABEL_BUILD_DIR"

# Acquire sel4.

# Match sel4 foundation selected version of sel4.
cd "$LABEL_BUILD_DIR"
if [[ -n "${SEL4_BRANCH}" ]]
then
    as_root git clone --branch "${SEL4_BRANCH}" "${SEL4_REPO}" sel4
else
    as_root git clone "${SEL4_REPO}" sel4
fi
if [[ -n "${SEL4_COMMIT}" ]]
then
    cd "$LABEL_BUILD_DIR/sel4"
    as_root git reset --hard "${SEL4_COMMIT}"
fi

# Acquire microkit.
cd "$LABEL_BUILD_DIR"
if [[ -n "${MICROKIT_BRANCH}" ]]
then
    as_root git clone --branch "${MICROKIT_BRANCH}" "${MICROKIT_REPO}" microkit
else
    as_root git clone "${MICROKIT_REPO}" microkit
fi
if [[ -n "${MICROKIT_COMMIT}" ]]
then
    cd "$LABEL_BUILD_DIR/microkit"
    as_root git reset --hard "${MICROKIT_COMMIT}"
fi

# Achieve Python requirements.
cd "$LABEL_BUILD_DIR"
python3.9 -m venv "pyenv"
"$LABEL_BUILD_DIR/pyenv/bin/pip" install --upgrade pip setuptools wheel
"$LABEL_BUILD_DIR/pyenv/bin/pip" install -r "$LABEL_BUILD_DIR/microkit/requirements.txt"

# Build.
cd "$LABEL_BUILD_DIR/microkit"
"$LABEL_BUILD_DIR/pyenv/bin/python" build_sdk.py --sel4="$LABEL_BUILD_DIR/sel4"

# Retain built release.
mv "$LABEL_BUILD_DIR/microkit/release" "$TARGET_DIR/$LABEL"

## Discard build area.
#rm -rf "$BUILD_DIR"
#
#
