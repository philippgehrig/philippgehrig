#!/usr/bin/env bash
# Desktop: GDM3 as display manager, GNOME (fallback session + apps),
# niri (scrollable-tiling Wayland compositor) with DMS (Dank Material Shell) on top.

log "GNOME + GDM3"
apt_install_rec task-gnome-desktop gdm3 gnome-tweaks gnome-browser-connector \
  xdg-desktop-portal-gnome xdg-desktop-portal-gtk
sudo systemctl enable gdm3

log "niri + DMS + quickshell + terminal"
# quickshell is also offered via trixie-backports; DMS pulls what it needs from its repo.
apt_install_rec niri dms quickshell ghostty xwayland-satellite grim wf-recorder \
  matugen xdotool wl-clipboard
apt_install dux-calendar dux-files dux-greeter dux-search

log "Fonts"
apt_install fonts-firacode fonts-jetbrains-mono fonts-cantarell

log "Desktop apps"
apt_install_rec evolution evolution-data-server nautilus file-roller evince loupe \
  shotwell baobab gnome-disk-utility gnome-system-monitor seahorse \
  libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-gtk3 \
  libreoffice-gnome libreoffice-help-en-us

log "Media codecs"
apt_install ffmpeg gstreamer1.0-libav gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly

log "Per-user session wiring (environment, DMS under niri)"
install -D -m 0644 /dev/stdin "$HOME/.config/environment.d/90-dms.conf" <<'EOF'
ELECTRON_OZONE_PLATFORM_HINT=auto
TERMINAL=ghostty
EOF
# Start DMS together with the niri session.
systemctl --user add-wants niri.service dms.service 2>/dev/null \
  || warn "Could not wire dms into niri.service (no user bus?). Run later: systemctl --user add-wants niri.service dms.service"
