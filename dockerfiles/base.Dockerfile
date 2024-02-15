ARG BASE_IMG=debian:bullseye-20210816-slim
FROM $BASE_IMG
LABEL ORGANISATION="https://github.com/sel4-cap"
LABEL MAINTAINER="https://github.com/Bill-James-Ellis"

ARG SCRIPT=base.sh


# BJE: why is clean, not part of the core script?


# Run the paired script.
ARG STAMP
COPY scripts/${SCRIPT} /tmp/${SCRIPT}
RUN --mount=type=ssh /bin/bash /tmp/${SCRIPT} \
    && apt-get clean autoclean \
    && apt-get autoremove --purge --yes 

# ENV variables persit in container.
ENV CURL_HOME "/util/curl_home"
ENV STAMP_BASE="BASE:${STAMP}"
