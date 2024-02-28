ARG BASE_IMG=ghcr.io/sel4-cap/cap
FROM $BASE_IMG
LABEL ORGANISATION="https://github.com/sel4-cap"
LABEL MAINTAINER="https://github.com/Bill-James-Ellis"

ARG SCRIPT=sdk.sh

# Run the paired script.
ARG STAMP
COPY scripts/${SCRIPT} /tmp/${SCRIPT}
COPY instructions /tmp/instructions

RUN --mount=type=ssh /bin/bash /tmp/${SCRIPT}

# ENV variables persit in container.
ENV STAMP_SDK="SDK:${STAMP}"
