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

RUN apk update && apk add --no-cache openssh-server openssh-client python3
RUN install --directory --mode 700 /var/run/sshd \
    && install --directory --mode 700 ${HOST_KEYS_PATH}

RUN addgroup -g ${USER_GID} ${USERNAME} \
    && adduser -D -u ${USER_UID} -G ${USERNAME} -h ${HOMEDIR} -s /bin/sh ${USERNAME} \
    && chmod 500 ${HOMEDIR}

# Disable shell history for the bastion account
RUN echo "export HISTFILE=/dev/null" >> /etc/profile.d/shell-history.sh

COPY --chmod=755 bastion-entrypoint.sh /bastion-entrypoint.sh

VOLUME /usr/local/etc/ssh /var/lib/bastion/.ssh/authorized_keys /etc/motd
EXPOSE 22
ENTRYPOINT ["/bastion-entrypoint.sh"]
