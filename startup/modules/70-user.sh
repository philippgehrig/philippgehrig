#!/usr/bin/env bash
# Per-user setup: shell PATH, git credential helpers, repositories.

log "Shell PATH (~/.bashrc managed block)"
managed_block "$HOME/.bashrc" startup-path '
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.opencode/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'

log "Git credential helpers (gh for GitHub, glab for DHBW GitLab)"
git config --global --replace-all credential.https://github.com.helper ''
git config --global --add credential.https://github.com.helper '!/usr/bin/gh auth git-credential'
git config --global --replace-all credential.https://git.dhbw-engineering.de.helper ''
git config --global --add credential.https://git.dhbw-engineering.de.helper '!/usr/bin/glab auth git-credential'
git config --global init.defaultBranch main
git config --global core.pager delta
git config --global user.name  >/dev/null || warn "git user.name not set"
git config --global user.email >/dev/null || warn "git user.email not set"

log "Repositories (~/repos)"
mkdir -p "$HOME/repos"
clone() { # clone <url> <dir>
  [ -d "$HOME/repos/$2/.git" ] && return 0
  git clone "$1" "$HOME/repos/$2" || warn "clone failed: $1 (authenticate with 'gh auth login' / 'glab auth login', then re-run: ./install.sh 70-user)"
}
clone https://github.com/philippgehrig/philippgehrig.git philippgehrig
clone https://github.com/philippgehrig/cv.git cv
clone https://git.dhbw-engineering.de/CFD/toolchain.git cfd-toolchain

warn "Not automated: logins (gh/glab/Enpass/Discord/Steam/Claude), niri+DMS personal config (~/.config/niri, ~/.config/DankMaterialShell)."
