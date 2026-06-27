# Debian-Docker-Install

One-click installer for **Docker Engine CE** on Debian, including Debian 13 (Trixie).

This repository provides a simple shell script that adds Docker's official APT repository, installs Docker Engine and the standard Docker plugins, enables the Docker service, and runs a quick verification step.[1]

## What it installs

The installer sets up the following packages from Docker's official Debian repository:[1]

- `docker-ce`
- `docker-ce-cli`
- `containerd.io`
- `docker-buildx-plugin`
- `docker-compose-plugin`

## Supported systems

This project is intended for Debian systems, especially Debian 13 (`trixie`). Docker documents Debian installation through its official repository, and Docker publishes Debian packages through `download.docker.com`.[1][2]

## Quick start

Clone the repository and run the installer as root:

```bash
git clone https://github.com/thejohnd0e/Debian-Docker-Install.git
cd Debian-Docker-Install
chmod +x debian-docker-install.sh
sudo ./debian-docker-install.sh
```

Or run it directly from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/thejohnd0e/Debian-Docker-Install/master/debian-docker-install.sh | sudo bash
```

## What the script does

The installer performs these steps based on Docker's official Debian installation flow:[1]

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

A common Debian installation problem is that `apt` cannot find `docker-ce` or related packages when Docker's official repository is missing or not configured for the correct Debian release.[1][3]

This repository wraps the official installation flow into a reusable one-click script so a fresh server can be prepared quickly and consistently.[1]

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
