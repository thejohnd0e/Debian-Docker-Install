#!/usr/bin/env bash
set -Eeuo pipefail

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

need_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    fail "Run as root: sudo bash $0"
  fi
}

detect_os() {
  [[ -r /etc/os-release ]] || fail "Cannot detect OS"
  . /etc/os-release

  [[ "${ID:-}" == "debian" ]] || fail "This script supports Debian only. Detected: ${ID:-unknown}"
  CODENAME="${VERSION_CODENAME:-}"
  ARCH="$(dpkg --print-architecture)"

  [[ -n "${CODENAME}" ]] || fail "Cannot detect Debian codename"

  if [[ "${CODENAME}" != "trixie" ]]; then
    log "Warning: detected Debian codename '${CODENAME}', not 'trixie'"
    log "The script will continue with detected codename."
  fi
}

pkg_installed() {
  dpkg-query -W -f='${Status}\n' "$1" 2>/dev/null | grep -q "install ok installed"
}

docker_repo_present() {
  grep -Rqs "https://download.docker.com/linux/debian" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
}

all_components_installed() {
  pkg_installed docker-ce &&
  pkg_installed docker-ce-cli &&
  pkg_installed containerd.io &&
  pkg_installed docker-buildx-plugin &&
  pkg_installed docker-compose-plugin
}

show_versions() {
  docker --version || true
  docker compose version || true
  docker buildx version || true
}

cleanup_old_docker_repo_files() {
  log "[2/8] Cleaning old Docker repository definitions..."

  rm -f /etc/apt/sources.list.d/docker.list
  rm -f /etc/apt/sources.list.d/docker-ce.list
  rm -f /etc/apt/sources.list.d/archive_uri-https_download_docker_com_linux_debian-*.list
  rm -f /etc/apt/sources.list.d/archive_uri-https_download_docker_com_linux_debian-*.sources

  if [[ -f /etc/apt/sources.list ]]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%s)
    sed -i '\|https://download.docker.com/linux/debian|d' /etc/apt/sources.list
  fi
}

install_prereqs() {
  log "[3/8] Installing prerequisites..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y ca-certificates curl gnupg
}

setup_keyring() {
  log "[4/8] Setting up Docker GPG key..."
  install -m 0755 -d /etc/apt/keyrings

  rm -f /etc/apt/keyrings/docker.gpg
  rm -f /etc/apt/keyrings/docker.asc

  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
}

setup_repo() {
  log "[5/8] Adding Docker APT repository..."
  cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF
}

remove_conflicting_packages() {
  log "[6/8] Removing conflicting old packages if present..."
  apt-get remove -y docker docker-engine docker.io containerd runc || true
}

install_docker() {
  log "[7/8] Installing Docker Engine and plugins..."
  apt-get update
  apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

enable_and_test() {
  log "[8/8] Enabling and testing Docker..."
  systemctl enable --now docker
  show_versions
  docker run --rm hello-world
}

main() {
  need_root

  log "[1/8] Checking OS..."
  detect_os

  if all_components_installed; then
    log "Docker Engine and all required plugins are already installed."
    show_versions
    systemctl enable --now docker >/dev/null 2>&1 || true
    exit 0
  fi

  if docker_repo_present; then
    log "Existing Docker repository configuration detected."
    log "It will be normalized to avoid Signed-By conflicts."
  fi

  cleanup_old_docker_repo_files
  install_prereqs
  setup_keyring
  setup_repo
  remove_conflicting_packages
  install_docker
  enable_and_test

  log
  log "Docker installed successfully."
}

main "$@"
