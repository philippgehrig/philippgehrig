#!/usr/bin/env bash
# Shared helpers. Sourced by install.sh and every module.

STARTUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILES_DIR="$STARTUP_DIR/files"
KEYRING_DIR=/etc/apt/keyrings
APT_UPDATE_NEEDED=0

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

apt_update() { sudo apt-get update -qq; APT_UPDATE_NEEDED=0; }
apt_install() { sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"; }
# Same, but let Recommends in (needed for desktop meta packages and nvidia-driver).
apt_install_rec() { sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"; }

# add_apt_key <url> <name>  -> /etc/apt/keyrings/<name>.gpg (binary, dearmored)
add_apt_key() {
  local url=$1 name=$2 tmp
  sudo install -d -m 0755 "$KEYRING_DIR"
  tmp=$(mktemp)
  curl -fsSL "$url" -o "$tmp" || die "download failed: $url"
  if grep -q 'BEGIN PGP' "$tmp"; then
    sudo gpg --dearmor --yes -o "$KEYRING_DIR/$name.gpg" "$tmp"
  else
    sudo install -m 0644 "$tmp" "$KEYRING_DIR/$name.gpg"
  fi
  sudo chmod 0644 "$KEYRING_DIR/$name.gpg"
  rm -f "$tmp"
}

# write_root <path> <mode>  (content on stdin)
write_root() { sudo install -D -m "$2" /dev/stdin "$1"; }

# Replace a marked block in a user file (idempotent).
managed_block() {
  local file=$1 tag=$2 content=$3
  touch "$file"
  sed -i "/^# >>> $tag >>>/,/^# <<< $tag <<</d" "$file"
  printf '# >>> %s >>>\n%s\n# <<< %s <<<\n' "$tag" "$content" "$tag" >>"$file"
}
