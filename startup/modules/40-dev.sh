#!/usr/bin/env bash
# Development toolchains and dev tools.

log "Compilers + build tools"
apt_install build-essential cmake ninja-build pkg-config gettext \
  libssl-dev libglib2.0-dev libjpeg-dev libpugixml-dev libxcb-cursor-dev \
  libpolkit-agent-1-dev

log "Languages: Java, Go, Node.js, Python"
apt_install default-jdk-headless gradle maven golang-go nodejs npm \
  python3 python3-pip python3-venv python3-numpy python3-pil

log "Docker Engine (official repo)"
apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker containerd
sudo usermod -aG docker "$USER"

log "Rust (rustup, stable)"
if ! have rustup && [ ! -x "$HOME/.cargo/bin/rustup" ]; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
fi
"$HOME/.cargo/bin/rustup" component add clippy rustfmt rust-analyzer >/dev/null

log "npm global prefix (~/.npm-global) + ccusage"
npm config set prefix "$HOME/.npm-global"
npm install -g ccusage

log "Visual Studio Code (tarball in ~/.local/opt/vscode)"
if [ ! -x "$HOME/.local/opt/vscode/bin/code" ]; then
  tmp=$(mktemp -d)
  curl -fsSL 'https://update.code.visualstudio.com/latest/linux-x64/stable' -o "$tmp/vscode.tar.gz"
  mkdir -p "$HOME/.local/opt/vscode" "$HOME/.local/bin"
  tar -xzf "$tmp/vscode.tar.gz" -C "$HOME/.local/opt/vscode" --strip-components=1
  ln -sf "$HOME/.local/opt/vscode/bin/code" "$HOME/.local/bin/code"
  rm -rf "$tmp"
fi

log "Claude Code (native installer)"
have claude || [ -x "$HOME/.local/bin/claude" ] || curl -fsSL https://claude.ai/install.sh | bash

log "opencode"
[ -x "$HOME/.opencode/bin/opencode" ] || curl -fsSL https://opencode.ai/install | bash

log "process-compose (latest GitHub release)"
if [ ! -x "$HOME/.local/bin/process-compose" ]; then
  tmp=$(mktemp -d)
  curl -fsSL https://github.com/F1bonacc1/process-compose/releases/latest/download/process-compose_linux_amd64.tar.gz \
    | tar -xz -C "$tmp" process-compose
  install -D -m 0755 "$tmp/process-compose" "$HOME/.local/bin/process-compose"
  rm -rf "$tmp"
fi
