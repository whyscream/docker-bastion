# Docker SSH bastion image

This Docker image provides a lightweight SSH bastion host based on Alpine Linux. It is designed to facilitate secure SSH access to internal networks or servers.

## Features
- Based on Alpine Linux for a minimal footprint
- OpenSSH server pre-installed and configured
- Enforces public key authentication
- Configurable via environment variables

## Usage

Add your public SSH keys to the `authorized_keys` file to allow access. You can mount this file into the container at runtime.

SSH host keys are generated automatically on the first run. You'll want to store these keys outside the container to ensure they persist across restarts. You can do this by mounting a volume to `/usr/local/etc/ssh`.

To start the SSH bastion container, use the following command:

```shell
docker build -t bastion .
docker run -d \
  -p 2222:22 \
  -v ./authorized_keys:/var/lib/bastion/.ssh/authorized_keys:ro \
  -v ./host_keys:/usr/local/etc/ssh:rw \
  -v ./motd:/etc/motd:ro \
  --name bastion bastion
```

To log in to the bastion host, use:

```shell
ssh -p 2222 bastion@<bastion-host>
```

All users will connect using the `bastion` username by default.

## Configuration

You can customize the SSH server configuration by setting environment variables.
For example, to enable X11 forwarding, you can run:
```shell
docker run -d \
  -e ALLOW_X11_FORWARDING=yes \
  -v ./authorized_keys:/var/lib/bastion/.ssh/authorized_keys:ro \
  -v ./host_keys:/usr/local/etc/ssh:rw \
  --name bastion bastion
```

Available environment variables:
- `LISTEN_PORT`: The port on which the SSH server listens (default: `22`)
- `LISTEN_ADDRESS`: The address on which the SSH server listens (default: `0.0.0.0`)
- `ALLOW_AGENT_FORWARDING`: Allow SSH agent forwarding (default: `yes`)
- `ALLOW_TCP_FORWARDING`: Allow TCP forwarding (default: `yes`)
- `ALLOW_X11_FORWARDING`: Allow X11 forwarding (default: `no`)

Build time environment variables:
- `USERNAME`: The username for SSH login (default: `bastion`)
- `USER_ID`: The user ID for the bastion user (default: `1000`)
- `GROUP_ID`: The group ID for the bastion user (default: `1000`)

## Thanks

Ideas taken from https://github.com/binlab/docker-bastion and many others

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
