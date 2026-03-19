# System Setup

## Hardware

- **Machine**: MacBook Pro (Apple T2)
- **CPU**: Intel Core i7-1068NG7 @ 2.30GHz
- **RAM**: 32GB
- **GPU**: Intel Iris Plus Graphics G7
- **Storage**: BTRFS

---

## System Layer (Kernel & Boot)

| Component | Setup |
|---|---|
| **Distro** | CachyOS (Arch-based, performance-optimized) |
| **Kernel** | linux-cachyos |
| **Init system** | systemd |

---

## Hardware & Driver Layer

| Component | Setup |
|---|---|
| **GPU drivers** | mesa (Intel Iris) |
| **Audio subsystem** | PipeWire (with WirePlumber + PulseAudio compat) |
| **Audio (T2-specific)** | apple-t2-audio-config, sof-firmware |
| **Networking** | iwd (WiFi), NetworkManager |
| **Bluetooth** | bluetooth daemon |
| **Power management** | power-profiles-daemon |
| **Suspend (T2)** | suspend-fix-t2.service (unloads apple-bce, brcmfmac_wcc, brcmfmac, touch bar modules + iwd/NM around sleep; S3 deep sleep) |
| **Fan control (T2)** | t2fanrd (enabled, active) |
| **Storage optimization** | Snapper (BTRFS snapshots, configured for root) |

---

## Display Layer

| Component | Setup |
|---|---|
| **Display server** | Wayland (no Xorg) |
| **Compositor** | Hyprland (Wayland tiling) |
| **Display manager** | SDDM |
| **Session manager** | UWSM |

---

## Window Manager Layer (Standalone WM Setup)

| Component | Setup | Status |
|---|---|---|
| **Window manager** | Hyprland | ✅ |
| **Status bar** | quickshell | Phase 3 done (CPU, MEM, TEMP, battery, WiFi, BT live). Phase 4 (volume + tray) next. |
| **App launcher** | wofi | ✅ |
| **Notifications** | mako | ✅ top-right, 5s timeout, per-urgency rules |
| **Screenshot** | hyprshot | ✅ |
| **Wallpaper** | — | Using Hyprland default |
| **Screen lock** | hyprlock | ✅ `Super+Shift+L`; blurred screenshot + clock |
| **Idle/suspend daemon** | hypridle | ✅ 2 min dim → 3 min lock → 10 min suspend |
| **Clipboard** | wl-clipboard | ✅ |
| **Polkit agent** | hyprpolkitagent (at `/usr/local/libexec/`) | ✅ |

---

## Credential & Key Management

| Component | Setup |
|---|---|
| **Secret store** | gnome-keyring (secrets component only; autostarted via Hyprland exec-once) |
| **GPG agent** | gpg-agent (systemd user socket activation; also handles SSH via gpg-agent-ssh.socket) |
| **SSH agent** | gpg-agent (no separate ssh-agent; uses gpg-agent SSH emulation) |

> **Note**: `SSH_AUTH_SOCK` is not automatically set in shell sessions — SSH auth will silently fail without it. Fix by adding to `~/.config/fish/config.fish`:
> ```fish
> set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
> ```
> Socket path: `/run/user/1000/gnupg/S.gpg-agent.ssh`

---

## User-space Utilities

| Component | Setup |
|---|---|
| **Terminal** | Ghostty (primary) |
| **Shell** | Fish (with cachyos-fish-config) |
| **Editor** | Neovim (plugins: markview.nvim, transparent.nvim, wilder.nvim, telescope.nvim, colorscheme-persist.nvim) |
| **File manager** | Dolphin |
| **Browser** | Brave |
| **AUR helper** | Paru |
| **Firewall** | UFW |
| **Process scheduler** | ananicy-cpp |

---

## Fonts

- `ttf-meslo-nerd` — primary (Nerd Font, used in terminal)
- `noto-fonts` + `noto-fonts-cjk` + `noto-fonts-emoji` — system-wide coverage

---

## Notes

- Configs symlinked from `~/.config/` to this repo (repo is source of truth): `hypr/`, `nvim/`, `ghostty/`. Hyprland's inotify-based config watcher does not detect changes through symlinks, so auto-reload stopped working. Fixed upstream in [hyprwm/Hyprland#9219](https://github.com/hyprwm/Hyprland/pull/9219) (merged 2025-01-31). If still broken, use `Super+Shift+]` to manually reload (`hyprctl reload`).
- Monitors configured in `hyprland.conf`: `eDP-1` (internal, 1.07x scale), `DP-2` (external, 1.2x scale, centered above)
- Terminal set to `ghostty`, file manager `dolphin`, launcher `wofi`, browser `firefox` in Hyprland config
- `kidletime` (KDE idle detection library) is installed but not actively managing idle/suspend
- Kitty and Alacritty are installed but likely leftovers (Ghostty is the primary terminal)
