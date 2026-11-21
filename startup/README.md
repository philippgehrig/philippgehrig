# Startup: debian-tower

Rebuilds this workstation on a fresh **Debian 13 (trixie)** install. Idempotent, modular.

## Hardware this targets

| Part | Detail | Handled in |
| --- | --- | --- |
| GPU | NVIDIA RTX 3060 Ti (GA104), proprietary driver 550 (DKMS) | `20-nvidia` |
| iGPU / audio | Intel Alder Lake-S, SOF firmware | `10-system` |
| NIC | Realtek RTL8125 2.5GbE (`r8169`) | `10-system` |
| CPU | Intel, microcode | `10-system` |

## Usage

```bash
cd startup
./install.sh              # everything, in order
./install.sh 20-nvidia    # single module
./install.sh --list
```

Run as your normal user; sudo is used where required. Reboot afterwards.

## Modules

| Module | Contents |
| --- | --- |
| `00-apt` | Debian sources (contrib, non-free, non-free-firmware, backports); Docker, Chrome, Enpass, DMS and dux repos |
| `10-system` | Firmware, microcode, NetworkManager/OpenVPN, SSH, CUPS, PipeWire, Bluetooth, CLI tooling |
| `20-nvidia` | Driver, CUDA lib, Vulkan, i386 libs, modprobe options (modeset, VRAM preservation), suspend services |
| `30-desktop` | GDM3, GNOME, niri + DMS + quickshell, Ghostty, fonts, LibreOffice, Evolution, codecs |
| `40-dev` | Toolchains (gcc, Java, Go, Node, Python, Rust), Docker, VS Code, Claude Code, opencode, process-compose |
| `50-apps` | Chrome, Firefox, Enpass, Steam, Discord |
| `60-cfd` | Single-node Slurm with 1 GPU, munge, Xvfb, STAR-CCM+ check |
| `70-user` | PATH, git credential helpers, clones `cfd-toolchain`, `cv`, this repo |
| `80-starccm` | **Manual only**: runs the STAR-CCM+ installer from `installers/` (see below) |

## STAR-CCM+ (manual, after you have your passwords)

1. Copy the Siemens download (`STAR-CCM+*_linux-x86_64.tar.gz`) into `startup/installers/`
   (git-ignored), or point `STARCCM_INSTALLER_DIR` at another folder, e.g. a USB stick.
2. Run `./install.sh starccm`. It extracts the archive, runs the interactive installer
   into `/opt/Siemens`, and cleans up. It is skipped by the default `./install.sh` run.
   Needs ~2x the archive size free in `~/.cache` (override with `STARCCM_EXTRACT_DIR`).

## Not automated

- Logins: `gh auth login`, `glab auth login`, Enpass, Discord, Steam, Claude
- Personal niri / DMS config (`~/.config/niri`, DMS settings)
- Secure Boot: enroll the DKMS MOK on first boot if enabled
- Git identity (`user.name`, `user.email`)
