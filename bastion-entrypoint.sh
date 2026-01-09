#!/usr/bin/env sh

set -o errexit
set -o pipefail
#set -o xtrace

# Set a password for the bastion user
PASSWORD=$(dd if=/dev/urandom bs=1 count=15 status=none | base64)
echo "${USERNAME}:${PASSWORD}" | chpasswd
#printf "Password for user '%s': %s\n" "${USERNAME}" "${PASSWORD}"

# Ensure the SSH host keys exist
if [ ! -f "${HOST_KEYS_PATH}/ssh_host_rsa_key" ]; then
  printf "Generating SSH host keys...\n"
  ssh-keygen -A -f "${HOST_KEYS_PATH_PREFIX}"
else
  printf "SSH host keys already exist, skipping generation.\n"
fi

# Start the SSH daemon
/usr/sbin/sshd -D -e \
  -o "HostKey ${HOST_KEYS_PATH}/ssh_host_rsa_key" \
  -o "HostKey ${HOST_KEYS_PATH}/ssh_host_ecdsa_key" \
  -o "HostKey ${HOST_KEYS_PATH}/ssh_host_ed25519_key" \
  -o "PermitRootLogin no" \
  -o "PasswordAuthentication no" \
  -o "ChallengeResponseAuthentication no" \
  -o "PubkeyAuthentication yes" \
  -o "AllowUsers ${USERNAME}" \
  -o "AuthorizedKeysFile ${HOMEDIR}/.ssh/authorized_keys" \
  -o "AllowAgentForwarding ${ALLOW_AGENT_FORWARDING:-yes}" \
  -o "AllowTcpForwarding ${ALLOW_TCP_FORWARDING:-yes}" \
  -o "X11Forwarding ${ALLOW_X11_FORWARDING:-no}" \
  -o "LogLevel verbose" \
  -o "ListenAddress ${LISTEN_ADDRESS:-0.0.0.0}" \
  -o "Port ${LISTEN_PORT:-22}"
