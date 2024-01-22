ARG BASE_IMG=debian:bullseye-20210816-slim
FROM $BASE_IMG
LABEL ORGANISATION="https://github.com/sel4-cap"
LABEL MAINTAINER="https://github.com/Bill-James-Ellis"

ARG STAMP

ARG UTIL_DIR="/util"
ARG REPO_DIR="${UTIL_DIR}/repo"
ARG CURL_HOME_DIR="${UTIL_DIR}/curl_home"

ARG SCRIPT=base.sh
COPY scripts/utils/common.sh /tmp/utils/common.sh
COPY scripts/${SCRIPT} /tmp/${SCRIPT}

RUN /bin/bash /tmp/${SCRIPT} \
    && apt-get clean autoclean \
    && apt-get autoremove --purge --yes 

# ENV variables persit in container.
ENV CURL_HOME "/util/curl_home"
ENV STAMP_BASE="BASE:${STAMP}"
