#!/usr/bin/env bash
# MANUAL: interactive Siemens STAR-CCM+ installer. Not part of the default run:
#   ./install.sh starccm
#
# Put the download (tar.gz, extracted folder, or bare .aol) into startup/installers/
# (or set STARCCM_INSTALLER_DIR). You enter licence/install answers in the installer
# itself, so this works once you have your passwords from Enpass.
# Set STARCCM_FORCE=1 to reinstall over an existing installation.

INSTALLER_DIR="${STARCCM_INSTALLER_DIR:-$STARTUP_DIR/installers}"
PREFIX=/opt/Siemens

[ -t 0 ] || die "starccm needs an interactive terminal."

if [ -z "${STARCCM_FORCE:-}" ] && compgen -G "$PREFIX/*/STAR-CCM+*/star/bin" >/dev/null; then
  log "STAR-CCM+ already installed: $(ls -d $PREFIX/*/STAR-CCM+*/star/bin | head -n1) (STARCCM_FORCE=1 to reinstall)"
  return 0
fi

# --- locate the installer -------------------------------------------------------
shopt -s nullglob
archives=("$INSTALLER_DIR"/STAR-CCM+*.tar.gz "$INSTALLER_DIR"/STAR-CCM+*.tgz)
folders=("$INSTALLER_DIR"/starccm+_*/)
aols=("$INSTALLER_DIR"/STAR-CCM+*.aol)
shopt -u nullglob

cleanup=""
if [ ${#folders[@]} -gt 0 ]; then
  src="${folders[0]%/}"
elif [ ${#aols[@]} -gt 0 ]; then
  src="$INSTALLER_DIR"
elif [ ${#archives[@]} -gt 0 ]; then
  archive="${archives[0]}"
  work="${STARCCM_EXTRACT_DIR:-$HOME/.cache/starccm-installer}"
  mkdir -p "$work"
  need_kb=$(( $(stat -c %s "$archive") / 1024 * 2 ))
  avail_kb=$(df --output=avail -k "$work" | tail -n1)
  [ "$avail_kb" -gt "$need_kb" ] || die "not enough space in $work (need ~$((need_kb / 1048576)) GiB). Set STARCCM_EXTRACT_DIR."
  log "Extracting $(basename "$archive") to $work (large, takes a while)"
  tar -xzf "$archive" -C "$work"
  src=$(find "$work" -maxdepth 2 -name 'STAR-CCM+*.aol' -printf '%h\n' | head -n1)
  cleanup="$work"
else
  die "No STAR-CCM+ installer found in $INSTALLER_DIR. Put the .tar.gz there (see installers/README.md)."
fi

aol=$(find "$src" -maxdepth 1 -name 'STAR-CCM+*.aol' | head -n1)
[ -n "$aol" ] || die "No STAR-CCM+*.aol in $src"

# --- install --------------------------------------------------------------------
# /opt/Siemens is owned by the user so the installer runs unprivileged and can add
# its PATH lines to ~/.bashrc itself.
sudo install -d -o "$USER" -g "$USER" -m 0755 "$PREFIX"
chmod +x "$aol"
log "Starting installer (suggested target: $PREFIX). Follow its prompts."
( cd "$src" && "$aol" )

[ -z "$cleanup" ] || { log "Removing extracted installer"; rm -rf "$cleanup"; }

if compgen -G "$PREFIX/*/STAR-CCM+*/star/bin" >/dev/null; then
  log "STAR-CCM+ installed. Open a new shell for the updated PATH."
else
  warn "Installer finished but no STAR-CCM+ found under $PREFIX."
fi
