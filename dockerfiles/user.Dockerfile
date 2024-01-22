#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

ARG USER_BASE_IMG
# hadolint ignore=DL3006
FROM $USER_BASE_IMG

# Get user UID and username
ARG USERNAME
ARG UID
ARG GID
ARG GROUP
ARG LOCAL_LANG

COPY scripts/user.sh /tmp/

RUN /bin/bash /tmp/user.sh
