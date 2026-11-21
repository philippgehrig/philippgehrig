#!/usr/bin/env bash
# Debian 13 (trixie) apt sources: official repos incl. non-free firmware + backports,
# plus the third-party repos we use (Docker, Chrome, Enpass, DMS/dux).

[ "$(. /etc/os-release && echo "$VERSION_CODENAME")" = trixie ] || die "This setup targets Debian 13 (trixie)."

log "Debian sources (deb822, contrib + non-free + non-free-firmware + backports)"
if [ -f /etc/apt/sources.list ] && grep -qE '^\s*deb ' /etc/apt/sources.list; then
  sudo mv /etc/apt/sources.list "/etc/apt/sources.list.bak-$(date +%Y%m%d%H%M%S)"
fi
sudo rm -f /etc/apt/sources.list.d/trixie-backports.list
write_root /etc/apt/sources.list.d/debian.sources 0644 <<'EOF'
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: trixie trixie-updates trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: http://security.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

log "Third-party repositories"
add_apt_key https://download.docker.com/linux/debian/gpg docker
write_root /etc/apt/sources.list.d/docker.sources 0644 <<'EOF'
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: trixie
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.gpg
EOF

add_apt_key https://dl.google.com/linux/linux_signing_key.pub google-chrome
write_root /etc/apt/sources.list.d/google-chrome.sources 0644 <<'EOF'
Types: deb
URIs: https://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/google-chrome.gpg
EOF

add_apt_key https://apt.enpass.io/keys/enpass-linux.key enpass
write_root /etc/apt/sources.list.d/enpass.sources 0644 <<'EOF'
Types: deb
URIs: https://apt.enpass.io/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/enpass.gpg
EOF

# DMS (Dank Material Shell) + dux apps, built on the openSUSE build service.
OBS=https://download.opensuse.org/repositories/home:/duxlabs-dev
for repo in dms dux-repo; do
  add_apt_key "$OBS:/$repo/Debian_13/Release.key" "duxlabs-$repo"
  write_root "/etc/apt/sources.list.d/duxlabs-$repo.sources" 0644 <<EOF
Types: deb
URIs: $OBS:/$repo/Debian_13/
Suites: ./
Architectures: amd64
Signed-By: /etc/apt/keyrings/duxlabs-$repo.gpg
EOF
done

# Old per-repo .list files from earlier manual setups would duplicate the above.
sudo rm -f /etc/apt/sources.list.d/{docker,enpass,home-duxlabs-dev-dms,home-duxlabs-dev-dux-repo}.list

log "apt update + full upgrade"
apt_update
sudo DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y
