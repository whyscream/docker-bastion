FROM alpine:3.23.2
LABEL maintainer="Tom Hendrikx"

ENV HOST_KEYS_PATH_PREFIX=/usr/local/
ENV HOST_KEYS_PATH=${HOST_KEYS_PATH_PREFIX}etc/ssh

RUN apk add openssh
RUN mkdir -p /var/run/sshd \
    && chmod 700 /var/run/sshd \
    && mkdir -p ${HOST_KEYS_PATH}

COPY --chmod=755 bastion-entrypoint.sh /bastion-entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/bastion-entrypoint.sh"]
