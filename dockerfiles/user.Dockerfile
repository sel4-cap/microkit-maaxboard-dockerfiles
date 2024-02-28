ARG USER_BASE_IMG
FROM $USER_BASE_IMG

ARG UID
ARG USER_NAME
ARG GID
ARG GROUP_NAME
ARG LOCAL_LANG

# Prepare for invoking user.
RUN groupadd -g "${GID}" "${GROUP_NAME}"
RUN useradd -u "${UID}" -g "${GID}" "${USER_NAME}"
RUN passwd -d "${USER_NAME}"
RUN usermod -aG sudo "${USER_NAME}"

ARG SCRIPT=user.sh

# Run the paired script.
COPY scripts/${SCRIPT} /tmp/${SCRIPT}
RUN --mount=type=ssh /bin/bash /tmp/${SCRIPT}

# Become invoking user.
USER "${USER_NAME}"
