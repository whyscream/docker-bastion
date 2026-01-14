FROM alpine:3.23.2

ARG BUILD_DATE
ARG BUILD_VERSION
LABEL \
    org.opencontainers.image.source="https://github.com/whyscream/docker-bastion/" \
    org.opencontainers.image.description="A minimal SSH bastion host based on Alpine Linux." \
    org.opencontainers.image.licenses="BSD-3-Clause" \
    org.opencontainers.image.url="https://whyscream.github.io/docker-bastion/" \
    org.opencontainers.image.vendor="Tom Hendrikx <tom@whyscream.net>" \
    org.opencontainers.image.build-date="$BUILD_DATE" \
    org.opencontainers.image.version="$BUILD_VERSION"

ARG USERNAME=bastion
ARG HOMEDIR=/var/lib/${USERNAME}
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV USERNAME=${USERNAME}
ENV HOMEDIR=${HOMEDIR}
ENV HOST_KEYS_PATH_PREFIX=/usr/local/
ENV HOST_KEYS_PATH=${HOST_KEYS_PATH_PREFIX}etc/ssh

RUN apk update && apk add --no-cache \
    openssh=10.2_p1-r0 \
    python3=3.12.12-r0
RUN install --directory --mode 700 ${HOST_KEYS_PATH}

# Add user with a readonly home directory
RUN addgroup -g ${USER_GID} ${USERNAME} \
    && adduser -D -u ${USER_UID} -G ${USERNAME} -h ${HOMEDIR} -s /bin/sh ${USERNAME} \
    && chmod 500 ${HOMEDIR}

# Disable shell history for the bastion account
RUN echo "export HISTFILE=/dev/null" >> /etc/profile.d/shell-history.sh

COPY --chmod=755 bastion-entrypoint.sh /bastion-entrypoint.sh

VOLUME /usr/local/etc/ssh /var/lib/bastion/.ssh/authorized_keys /etc/motd
EXPOSE 22
ENTRYPOINT ["/bastion-entrypoint.sh"]
