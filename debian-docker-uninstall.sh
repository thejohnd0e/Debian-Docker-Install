#!/usr/bin/env bash

echo "=== Debian Docker Uninstaller ==="
echo ""

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: Run as root"
  exit 1
fi

echo "[1/5] Stopping Docker service..."
systemctl stop docker docker.socket containerd 2>/dev/null || true
systemctl disable docker docker.socket containerd 2>/dev/null || true

echo "[2/5] Removing Docker packages..."
DEBIAN_FRONTEND=noninteractive apt-get purge -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin \
  docker-ce-rootless-extras \
  docker-compose \
  docker \
  docker-engine \
  docker.io \
  containerd \
  runc 2>/dev/null || true

DEBIAN_FRONTEND=noninteractive apt-get autoremove -y 2>/dev/null || true

echo "[3/5] Removing Docker data..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

echo "[4/5] Removing Docker configuration and repository..."
rm -rf /etc/docker
rm -rf /root/.docker
rm -rf /home/*/.docker 2>/dev/null || true
rm -f /etc/apt/sources.list.d/docker.sources
rm -f /etc/apt/sources.list.d/docker.list
rm -f /etc/apt/sources.list.d/docker-ce.list
rm -f /etc/apt/keyrings/docker.asc
rm -f /etc/apt/keyrings/docker.gpg
rm -f /usr/share/keyrings/docker-archive-keyring.gpg
rm -f /usr/share/keyrings/docker.gpg
sed -i '\|https://download.docker.com/linux/debian|d' /etc/apt/sources.list 2>/dev/null || true

echo "[5/5] Removing docker group and socket..."
rm -f /var/run/docker.sock
groupdel docker 2>/dev/null || true

apt-get update 2>/dev/null || true

echo ""
echo "Docker has been completely uninstalled."
