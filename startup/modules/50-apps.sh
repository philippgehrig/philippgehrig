#!/usr/bin/env bash
# Desktop applications.

log "Browsers, password manager"
apt_install google-chrome-stable firefox-esr enpass

log "Steam (needs the i386 architecture from the nvidia module) + MangoHud"
sudo dpkg --add-architecture i386
apt_update
apt_install_rec steam-installer mangohud

log "Discord (no Debian package: official .deb)"
if ! dpkg -s discord >/dev/null 2>&1; then
  tmp=$(mktemp -d)
  curl -fsSL 'https://discord.com/api/download?platform=linux&format=deb' -o "$tmp/discord.deb"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmp/discord.deb"
  rm -rf "$tmp"
fi

log "Enpass autostart"
if [ -f /usr/share/applications/enpass.desktop ]; then
  install -D -m 0644 /usr/share/applications/enpass.desktop "$HOME/.config/autostart/Enpass.desktop"
fi
