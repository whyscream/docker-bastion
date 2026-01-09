#!/usr/bin/env sh

set -o errexit
set -o pipefail
#set -o xtrace

# Set a password for the bastion user
PASSWORD=$(dd if=/dev/urandom bs=1 count=15 status=none | base64)
echo "${USERNAME}:${PASSWORD}" | chpasswd
printf "Password for user '%s': %s\n" "${USERNAME}" "${PASSWORD}"

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
  -o "HostKey ${HOST_KEYS_PATH}/ssh_host_ed25519_key"
