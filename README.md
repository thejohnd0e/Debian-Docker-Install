# Debian Docker Install

One-click installer for **Docker Engine CE** on Debian, including Debian 13 (Trixie).

Adds Docker's official APT repository, installs Docker Engine and the standard plugins, enables the Docker service, and runs a quick verification step.

## Features

- Safe re-run: detects if Docker and all plugins are already installed and exits cleanly
- Auto-fixes `Signed-By` conflicts caused by previously added Docker repositories
- Removes old conflicting packages before installation
- Supports any Debian release with a valid codename (optimized for Trixie)

## What it installs

- `docker-ce`
- `docker-ce-cli`
- `containerd.io`
- `docker-buildx-plugin`
- `docker-compose-plugin`

## Quick start

**Option 1 — run directly from GitHub:**

```bash
curl -fsSL https://raw.githubusercontent.com/thejohnd0e/Debian-Docker-Install/master/debian-docker-install.sh | sudo bash
```

**Option 2 — clone and run locally:**

```bash
git clone https://github.com/thejohnd0e/Debian-Docker-Install.git
cd Debian-Docker-Install
chmod +x debian-docker-install.sh
sudo ./debian-docker-install.sh
```

## What the script does

1. Checks that the host system is Debian
2. Detects the current Debian codename
3. Checks if all Docker components are already installed — exits early if yes
4. Detects and removes old Docker repository definitions to prevent `Signed-By` conflicts
5. Installs required dependencies: `ca-certificates`, `curl`, `gnupg`
6. Adds Docker's GPG key to `/etc/apt/keyrings/docker.asc`
7. Adds Docker's official APT repository
8. Removes old conflicting packages such as `docker.io`, `containerd`, `runc`
9. Installs Docker Engine and plugins
10. Enables and starts the Docker service
11. Runs a basic test with `hello-world`

## Re-running on a system with Docker already installed

If all required components are already installed, the script will print the installed versions and exit without making any changes:

```
Docker Engine and all required plugins are already installed.
Docker version 27.x.x, build xxxxxxx
Docker Compose version v2.x.x
```

## Verify installation manually

```bash
docker --version
docker compose version
sudo docker run --rm hello-world
```

## Known issues fixed

**`E: Conflicting values set for option Signed-By`**

This error occurs when Docker's repository was previously added with a different keyring file (`docker.gpg` vs `docker.asc`). The script automatically detects and removes all old Docker source definitions before creating a clean single-entry configuration.

## Security note

Reviewing the script before execution is recommended, especially on production systems.

## Requirements

- Debian GNU/Linux (any release with a valid codename)
- Root or sudo access
- Internet access to `download.docker.com` and `deb.debian.org`
