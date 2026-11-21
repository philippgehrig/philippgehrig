#!/usr/bin/env bash
# Rebuild this machine (debian-tower) on a fresh Debian 13 install.
#
#   ./install.sh                 run all modules in order
#   ./install.sh 20-nvidia 60-cfd  run selected modules (prefix or full name)
#   ./install.sh --list          list modules
#
# Run as your normal user (not root); sudo is used where needed. Safe to re-run.
set -Eeuo pipefail
[ "$EUID" -ne 0 ] || { echo "Run as a normal user, not root." >&2; exit 1; }

# shellcheck source=lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

mapfile -t ALL < <(cd "$STARTUP_DIR/modules" && ls *.sh | sed 's/\.sh$//')

is_manual() { grep -q '^# MANUAL' "$STARTUP_DIR/modules/$1.sh"; }

if [ "${1:-}" = "--list" ]; then
  for m in "${ALL[@]}"; do is_manual "$m" && echo "$m  (manual)" || echo "$m"; done
  exit 0
fi

selected=()
if [ $# -eq 0 ]; then
  for m in "${ALL[@]}"; do is_manual "$m" || selected+=("$m"); done   # manual modules are opt-in
else
  for want in "$@"; do
    # match full name, number prefix ("20"), or name after the number ("nvidia")
    match=$(printf '%s\n' "${ALL[@]}" | grep -E "^${want}(\.sh)?$|^${want}|^[0-9]+-${want}$" | head -n1 || true)
    [ -n "$match" ] || die "unknown module: $want (see --list)"
    selected+=("$match")
  done
fi

sudo -v
trap 'die "failed in module: ${current:-?} (line $LINENO)"' ERR

for current in "${selected[@]}"; do
  log "### module $current"
  # shellcheck source=/dev/null
  source "$STARTUP_DIR/modules/$current.sh"
done

log "Done. Reboot (NVIDIA driver, docker group, GDM)."
