#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/7] Checking OS..."
if [[ ! -r /etc/os-release ]]; then
  echo "Cannot detect OS"
  exit 1
fi

. /etc/os-release

if [[ "${ID:-}" != "debian" ]]; then
  echo "This script supports Debian only. Detected: ${ID:-unknown}"
  exit 1
fi

CODENAME="${VERSION_CODENAME:-}"
ARCH="$(dpkg --print-architecture)"

if [[ -z "${CODENAME}" ]]; then
  echo "Cannot detect Debian codename"
  exit 1
fi

if [[ "${CODENAME}" != "trixie" ]]; then
  echo "Warning: detected Debian codename '${CODENAME}', not 'trixie'"
  echo "The script will continue with detected codename."
fi

echo "[2/7] Removing conflicting old packages if present..."
apt-get update
apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "[3/7] Installing prerequisites..."
apt-get install -y ca-certificates curl gnupg

echo "[4/7] Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "[5/7] Adding Docker APT repository..."
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "[6/7] Installing Docker Engine and plugins..."
apt-get update
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "[7/7] Enabling and testing Docker..."
systemctl enable --now docker
docker --version
docker compose version
docker run --rm hello-world

echo
echo "Docker installed successfully."
