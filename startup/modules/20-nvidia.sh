#!/usr/bin/env bash
# NVIDIA GeForce RTX 3060 Ti (GA104) on the Debian-packaged proprietary driver (DKMS).
# i386 libs are needed for Steam / 32-bit Vulkan + GL.

if ! lspci -nn | grep -qi 'nvidia'; then
  warn "No NVIDIA GPU detected, skipping."; return 0
fi

log "Enable i386 + refresh"
sudo dpkg --add-architecture i386
apt_update

log "NVIDIA driver (DKMS), CUDA runtime lib, Vulkan, 32-bit libs"
apt_install_rec nvidia-driver nvidia-kernel-dkms nvidia-smi nvidia-settings \
  nvidia-persistenced nvidia-detect firmware-nvidia-gsp libcuda1 \
  libnvidia-encode1 nvidia-vulkan-icd vulkan-tools \
  nvidia-driver-libs:i386 libgl1-nvidia-glvnd-glx:i386 nvidia-vulkan-icd:i386 \
  mesa-vulkan-drivers mesa-va-drivers mesa-vdpau-drivers libglu1-mesa

log "Kernel module options (Wayland modeset, VRAM preservation across suspend)"
for f in nvidia-drm-modeset.conf nvidia-preserve-vram.conf; do
  sudo install -D -m 0644 "$FILES_DIR/modprobe/$f" "/etc/modprobe.d/$f"
done

log "Services"
sudo systemctl enable nvidia-persistenced nvidia-suspend nvidia-hibernate nvidia-resume

log "Rebuild initramfs"
sudo update-initramfs -u

warn "Reboot required before the driver is active. Secure Boot: enroll the DKMS MOK when prompted."
