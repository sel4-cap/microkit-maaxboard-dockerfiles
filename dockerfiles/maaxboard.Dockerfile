ARG BASE_IMG=ghcr.io/sel4-cap/microkit
FROM $BASE_IMG
LABEL ORGANISATION="https://github.com/sel4-cap"
LABEL MAINTAINER="https://github.com/Bill-James-Ellis"

ARG STAMP

ARG SCRIPT=maaxboard.sh

COPY scripts/${SCRIPT} /tmp/${SCRIPT}

RUN /bin/bash /tmp/${SCRIPT} \
    && apt-get clean autoclean \
    && apt-get autoremove --purge --yes \
    && rm -rf /var/lib/apt/lists/*

# ENV variables persit in container.
ENV STAMP_MAAXBOARD="MAAXBOARD:${STAMP}"
