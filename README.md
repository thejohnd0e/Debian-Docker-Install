# Debian-Docker-Install

One-click installer for **Docker Engine CE** on Debian, with support for Debian 13 (Trixie).

This repository provides a simple shell script that adds Docker's official APT repository, installs Docker Engine and the standard plugins, enables the Docker service, and runs a quick verification step.[1][2]

## What it installs

The installer sets up the following Docker packages from the official Docker Debian repository:[1]

- `docker-ce`
- `docker-ce-cli`
- `containerd.io`
- `docker-buildx-plugin`
- `docker-compose-plugin`

## Supported systems

This project is intended for Debian systems, especially Debian 13 (`trixie`). Docker provides Debian installation instructions through its official Debian repository, and the `trixie` distribution is present in Docker's Debian package index.[1][2]

## Quick start

Clone the repository and run the installer as root:

```bash
git clone https://github.com/thejohnd0e/Debian-Docker-Install.git
cd Debian-Docker-Install
chmod +x install-docker-debian.sh
sudo ./install-docker-debian.sh
```

Or run it directly from GitHub with `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/thejohnd0e/Debian-Docker-Install/master/install-docker-debian.sh | sudo bash
```

## What the script does

The installer performs these steps:[1]

1. Checks that the host system is Debian.
2. Detects the current Debian codename.
3. Removes old or conflicting Docker-related packages when present.
4. Installs required dependencies such as `ca-certificates`, `curl`, and `gnupg`.
5. Adds Docker's GPG key.
6. Adds Docker's official APT repository.
7. Installs Docker Engine and plugins.
8. Enables and starts the Docker service.
9. Runs a basic test with `hello-world`.

## Why this repository exists

A common Debian installation issue is that `apt` cannot find `docker-ce` or related packages when Docker's official repository is missing or not configured for the correct Debian release.[1][2]

This repository packages the official installation flow into a reusable one-click script so a fresh server can be prepared quickly and consistently.[1]

## Verify installation

After installation, these commands should work:

```bash
docker --version
docker compose version
sudo docker run --rm hello-world
```

## Security note

Running remote shell scripts with `curl | bash` is convenient, but reviewing the script before execution is safer, especially on production systems.

## License

Add a license file if you want to make reuse terms explicit.
