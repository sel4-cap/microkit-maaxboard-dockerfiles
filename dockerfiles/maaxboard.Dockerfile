#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

ARG BASE_IMG=ghcr.io/sel4-cap/microkit
# hadolint ignore=DL3006
FROM $BASE_IMG
LABEL ORGANISATION="Trustworthy Systems"
LABEL MAINTAINER="Luke Mondy (luke.mondy@data61.csiro.au)"

# ARGS are env vars that are *only available* during the docker build
# They can be modified at docker build time via '--build-arg VAR="something"'
ARG STAMP
ARG SCM
ARG USE_DEBIAN_SNAPSHOT=yes
ARG DESKTOP_MACHINE=no
ARG MAKE_CACHES=yes

ARG SCRIPT=maaxboard.sh

COPY scripts/${SCRIPT} /tmp/${SCRIPT}

RUN /bin/bash /tmp/${SCRIPT} \
    && apt-get clean autoclean \
    && apt-get autoremove --purge --yes \
    && rm -rf /var/lib/apt/lists/*

# ENV variables are available to containers after the build stage.
ENV STAMP_MAAXBOARD="MAAXBOARD:${STAMP}"
