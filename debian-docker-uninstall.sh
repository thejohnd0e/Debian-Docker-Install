#!/usr/bin/env bash
set -Eeuo pipefail

log()  { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

need_root() {
  [[ "${EUID}" -ne 0 ]] && fail "Run as root: sudo bash $0"
}

fix_hostname() {
  local hn
  hn="$(hostname)"
  if ! grep -qE "(^127\.|^::1)[[:space:]].*\b${hn}\b" /etc/hosts 2>/dev/null; then
    log "Fixing /etc/hosts: adding hostname '${hn}'..."
    echo "127.0.0.1 ${hn}" >> /etc/hosts
  fi
}

pkg_installed() {
  dpkg-query -W -f='${Status}\n' "$1" 2>/dev/null | grep -q "install ok installed"
}

any_docker_installed() {
  pkg_installed docker-ce ||
  pkg_installed docker-ce-cli ||
  pkg_installed containerd.io ||
  pkg_installed docker-buildx-plugin ||
  pkg_installed docker-compose-plugin
}

confirm() {
  read -r -p "Are you sure you want to uninstall Docker and remove all related data? [y/N] " reply
  case "${reply}" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) log "Aborted."; exit 0 ;;
  esac
}

stop_docker() {
  log "[1/6] Stopping Docker service..."
  systemctl stop docker docker.socket containerd 2>/dev/null || true
  systemctl disable docker docker.socket containerd 2>/dev/null || true
  log "Docker service stopped and disabled."
}

remove_packages() {
  log "[2/6] Removing Docker packages..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get purge -y \
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
    runc \
    2>/dev/null || true
  apt-get autoremove -y 2>/dev/null || true
  log "Packages removed."
}

remove_data() {
  log "[3/6] Removing Docker data (images, containers, volumes, networks)..."
  rm -rf /var/lib/docker
  rm -rf /var/lib/containerd
  log "Docker data removed."
}

remove_config() {
  log "[4/6] Removing Docker configuration..."
  rm -rf /etc/docker
  rm -rf /root/.docker
  rm -rf /home/*/.docker 2>/dev/null || true
  log "Docker configuration removed."
}

remove_repo() {
  log "[5/6] Removing Docker APT repository and GPG key..."
  rm -f /etc/apt/sources.list.d/docker.sources
  rm -f /etc/apt/sources.list.d/docker.list
  rm -f /etc/apt/sources.list.d/docker-ce.list
  rm -f /etc/apt/keyrings/docker.asc
  rm -f /etc/apt/keyrings/docker.gpg
  rm -f /usr/share/keyrings/docker-archive-keyring.gpg
  rm -f /usr/share/keyrings/docker.gpg
  if [[ -f /etc/apt/sources.list ]]; then
    sed -i '\|https://download.docker.com/linux/debian|d' /etc/apt/sources.list
  fi
  apt-get update 2>/dev/null || true
  log "Docker repository removed."
}

remove_leftovers() {
  log "[6/6] Removing leftover sockets and docker group..."
  rm -f /var/run/docker.sock
  groupdel docker 2>/dev/null || true
  log "Done."
}

main() {
  need_root
  fix_hostname
  log "=== Debian Docker Uninstaller ==="
  log ""
  if ! any_docker_installed; then
    log "Docker components are not installed. Nothing to uninstall."
    exit 0
  fi
  log "The following will be removed:"
  log "  - Docker Engine packages (docker-ce, docker-ce-cli, containerd.io, plugins)"
  log "  - All Docker data: images, containers, volumes, networks (/var/lib/docker)"
  log "  - Docker configuration (/etc/docker, ~/.docker)"
  log "  - Docker APT repository and GPG key"
  log "  - Docker group"
  log ""
  confirm
  stop_docker
  remove_packages
  remove_data
  remove_config
  remove_repo
  remove_leftovers
  log ""
  log "Docker has been completely uninstalled."
}

main "$@"
