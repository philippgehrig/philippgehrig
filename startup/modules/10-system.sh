#!/usr/bin/env bash
# Firmware, CPU microcode, base system services, networking, CLI tooling.
# Hardware: Intel Alder Lake-S (iGPU firmware, SOF audio), Realtek RTL8125 2.5GbE.

log "Firmware + microcode"
apt_install firmware-intel-graphics firmware-realtek firmware-sof-signed \
  intel-microcode fwupd

log "Kernel headers (for DKMS), locale, time, power"
apt_install linux-headers-amd64 dkms locales locales-all \
  systemd-timesyncd power-profiles-daemon low-memory-monitor

log "Networking + remote access"
apt_install network-manager network-manager-openvpn network-manager-openvpn-gnome \
  openvpn openssh-server openssh-client avahi-daemon nftables \
  systemd-resolved libnss-resolve bind9-dnsutils traceroute iputils-ping \
  netcat-traditional inetutils-telnet
sudo systemctl enable --now NetworkManager ssh avahi-daemon

log "Printing"
apt_install cups system-config-printer-udev simple-scan
sudo systemctl enable --now cups

log "Audio + Bluetooth"
apt_install pipewire-audio pipewire-alsa pipewire-pulse wireplumber bluez

log "CLI tooling"
apt_install bash-completion curl wget ca-certificates gnupg unzip xz-utils zstd \
  bzip2 file less man-db jq lsof pciutils usbutils dmidecode sensible-utils \
  git git-delta gh glab lazygit \
  htop tmux vim neovim nano \
  ripgrep fd-find fzf bat eza zoxide starship direnv httpie just \
  zsh zsh-autosuggestions zsh-syntax-highlighting
