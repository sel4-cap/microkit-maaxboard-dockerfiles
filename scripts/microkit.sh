#!/bin/bash
#
# This script adds and removes packages to control those required
# for building for the Avnet MaaxBoard. 
#
# SPDX-License-Identifier: BSD-2-Clause
#

set -exuo pipefail

# Source common functions
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"



# Get the public / SDK / and build it... ? Pick a revision? Put it where?

