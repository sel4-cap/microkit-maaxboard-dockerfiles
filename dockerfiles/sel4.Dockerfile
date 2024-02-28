ARG BASE_IMG=ghcr.io/sel4-cap/base
FROM $BASE_IMG
LABEL ORGANISATION="https://github.com/sel4-cap"
LABEL MAINTAINER="https://github.com/Bill-James-Ellis"

ARG SCRIPT=sel4.sh

# Run the paired script.
ARG STAMP
COPY scripts/${SCRIPT} /tmp/${SCRIPT}
RUN --mount=type=ssh /bin/bash /tmp/${SCRIPT}

# ENV variables persit in container.
ENV STAMP_SEL4="SEL4:${STAMP}"
