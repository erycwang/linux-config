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
| **Fan control (T2)** | t2fanrd (installed, currently disabled) |
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
| **Status bar** | — | Not installed |
| **App launcher** | wofi | ✅ |
| **Notifications** | — | Not installed |
| **Wallpaper** | — | Using Hyprland default |
| **Screen lock** | — | Not installed |
| **Idle/suspend daemon** | kidletime (installed, unused) | Not configured |
| **Clipboard** | wl-clipboard | ✅ |
| **Polkit agent** | hyprpolkitagent (at `/usr/local/libexec/`) | ✅ |

---

## User-space Utilities

| Component | Setup |
|---|---|
| **Terminal** | Ghostty (primary) |
| **Shell** | Fish (with cachyos-fish-config) |
| **Editor** | Neovim |
| **File manager** | Dolphin |
| **Browser** | Firefox (primary; planning to switch to Brave w/ keyring) |
| **AUR helper** | Paru |
| **Firewall** | UFW |
| **Process scheduler** | ananicy-cpp |

---

## Fonts

- `ttf-meslo-nerd` — primary (Nerd Font, used in terminal)
- `noto-fonts` + `noto-fonts-cjk` + `noto-fonts-emoji` — system-wide coverage

---

## Notes

- Monitors configured in `hyprland.conf`: `eDP-1` (internal, 1.07x scale), `DP-2` (external, 1.2x scale, centered above)
- Terminal set to `ghostty`, file manager `dolphin`, launcher `wofi`, browser `firefox` in Hyprland config
- `kidletime` (KDE idle detection library) is installed but not actively managing idle/suspend
- Kitty and Alacritty are installed but likely leftovers (Ghostty is the primary terminal)
- **t2fanrd status**: Installed but currently disabled. Enable with `systemctl enable --now t2fanrd` if you want active fan control.
- **hyprpolkitagent**: Runs successfully from `/usr/local/libexec/hyprpolkitagent` (non-standard PATH location)
