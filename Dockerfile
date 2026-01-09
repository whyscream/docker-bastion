FROM alpine:3.23.2
LABEL maintainer="Tom Hendrikx"

ARG USERNAME=bastion
ARG HOMEDIR=/var/lib/${USERNAME}
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV USERNAME=${USERNAME}
ENV HOMEDIR=${HOMEDIR}
ENV HOST_KEYS_PATH_PREFIX=/usr/local/
ENV HOST_KEYS_PATH=${HOST_KEYS_PATH_PREFIX}etc/ssh

RUN apk add openssh-server
RUN install --directory --mode 700 /var/run/sshd \
    && install --directory --mode 700 ${HOST_KEYS_PATH}

RUN addgroup -g ${USER_GID} ${USERNAME} \
    && adduser -D -u ${USER_UID} -G ${USERNAME} -h ${HOMEDIR} -s /bin/sh ${USERNAME}

COPY --chmod=755 bastion-entrypoint.sh /bastion-entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/bastion-entrypoint.sh"]
