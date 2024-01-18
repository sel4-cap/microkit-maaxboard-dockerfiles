#!/bin/sh
#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

if [ -z "${PERSONAL_ACCESS_TOKEN}" ]
then
    echo "Set environment variable: PERSONAL_ACCESS_TOKEN"
    exit 1
fi
if [ -z "${USERNAME}" ]
then
    echo "Set environment variable: USERNAME"
    exit 1
fi

# Login to GitHub Packages.
docker login ghcr.io --username "${USERNAME}" --password "${PERSONAL_ACCESS_TOKEN}"

# Push.
docker push ghcr.io/sel4-cap/sel4:latest


