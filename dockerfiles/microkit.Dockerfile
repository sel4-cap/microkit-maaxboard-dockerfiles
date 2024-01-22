ARG BASE_IMG=ghcr.io/sel4-cap/camkes
FROM $BASE_IMG
LABEL ORGANISATION="https://github.com/sel4-cap"
LABEL MAINTAINER="https://github.com/Bill-James-Ellis"

ARG STAMP

ARG SCRIPT=microkit.sh

COPY scripts/utils/add_microkit.sh /tmp/utils/add_microkit.sh
COPY scripts/${SCRIPT} /tmp/${SCRIPT}

RUN /bin/bash /tmp/${SCRIPT} \
    && apt-get clean autoclean \
    && apt-get autoremove --purge --yes 

# ENV variables persit in container.
ENV STAMP_MICROKIT="MICROKIT:${STAMP}"
