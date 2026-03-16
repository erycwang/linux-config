# Setup To-Do

Gaps and planned changes to the current system setup, ordered by priority.

---

## Priority 1 — Security & Power (do these first)

### Keyring daemon (gnome-keyring) ✅ Done

- `gnome-keyring` installed, autostarted in Hyprland with `--components=secrets` (secrets only — gpg-agent handles SSH/GPG)
- `gh auth login` re-run; token now stored in keyring (`gh auth status` confirms `(keyring)`)
- `hosts.yml` no longer contains `oauth_token`

---

### Lock screen + idle daemon ✅ Done

- `hyprlock` + `hypridle` installed
- `hypridle` autostarted via `exec-once` in Hyprland; idle chain: 2 min dim → 3 min lock → 10 min suspend
- `hyprlock` bound to `Super+Shift+L`; also triggered by `hypridle` and before suspend
- `kidletime` kept — pulled in by `baloo` → `dolphin`, cannot remove
- Lock screen: blurred screenshot background, clock, centered password input

---

### Suspend

**Hardware**: 2020 MacBook Pro 13" (T2 chip) — see `changes.md` for full fix history.

`/etc/systemd/system/suspend-fix-t2.service` unloads `apple-bce`, `brcmfmac`, and Touch Bar modules before sleep and reloads them on resume. S3 deep sleep confirmed working. See [t2linux wiki](https://wiki.t2linux.org/guides/postinstall/) for background.

**Remaining items**:
- [ ] Lid close triggers suspend, lid open resumes
- [ ] No spurious immediate wakeups (`XHC1`/`ARPT` ACPI wakeup sources not yet disabled)

---

## Priority 2 — Usability (important gaps)

### Status bar (quickshell)

**No status bar installed.** No visibility into workspaces, time, battery, network, etc.

- Install `quickshell` (AUR: `quickshell-git`)
- Write a QML config (quickshell uses QML/JS — significantly more powerful than waybar but more setup work)
- Minimum viable bar: workspaces, clock, battery, network indicator, volume
- Wire into Hyprland config

**Notes on quickshell**: It's newer and less documented than waybar. If the QML config becomes a blocker, waybar is a well-trodden fallback that can be swapped out later.

---

### Notification daemon

**No notifications configured.** System events (low battery, package alerts, etc.) are silent.

- Install `mako` (Wayland-native, minimal, config-file driven) or `dunst` (more featureful)
- Add `exec-once = mako` to Hyprland config
- Configure appearance and timeout

**Note**: `mako` is the lighter choice and fits the current minimal setup style.

---

## Priority 3 — Planned changes

### Browser migration: Firefox → Brave

- Already noted in `setup.md`
- Install `brave-bin` (AUR)
- Configure with system keyring for password storage (`kwallet` or `gnome-keyring`)
- Update default browser in Hyprland config once switched

---

## Priority 4 — Nice to have

### Screenshot tool — ✅ Done

- ~~Install `grim` + `slurp` (composable Wayland screenshot tools)~~
- ~~Or install `hyprshot` (wrapper around grim/slurp with Hyprland-aware window/region selection)~~ — installed `hyprshot`
- ~~Bind to a key in Hyprland config~~ — bound `Super+Shift+X` → `hyprshot -m region`

---

### OSD / HUD bars

Visual overlays for volume, brightness, and keyboard brightness on keypress. Common Wayland options:

- `swayosd` (AUR: `swayosd-git`) — runs as a background service, handles volume/brightness/caps lock natively, integrates cleanly with Hyprland
- `wob` — simpler pipe-based bar, requires wiring manually to each keybind

Recommended: `swayosd` — less wiring, handles all three use cases out of the box.

- Install and enable: `paru -S swayosd-git` + `exec-once = swayosd-server` in Hyprland config
- Update volume/brightness keybinds to call `swayosd-client` instead of raw `wpctl`/`brightnessctl`
- Add keyboard brightness keybind if not already present

---

### Wallpaper

- Install `hyprpaper` (Hyprland-native) or `swww` (supports animated wallpapers)
- Currently using Hyprland default (solid color)

---

### Cleanup orphaned terminals

- Kitty and Alacritty are installed but unused (Ghostty is primary)
- Uninstall if not dependencies of anything: `paru -Rns kitty alacritty`

---

### t2fanrd — ✅ Done

- Enabled via `systemctl enable --now t2fanrd`
- Custom config at `/etc/t2fand.conf`: logarithmic curve, 50°C–72°C
- Logarithmic: fans ramp quickly at low temps, flatten near max — more responsive at the low end, quieter under sustained load

---

## Summary table

| Item | Priority | Status |
|---|---|---|
| Keyring daemon (gnome-keyring) | 🟢 Done | ✅ Token in keyring, hosts.yml clean |
| Lock screen (hyprlock + hypridle) | 🟢 Done | ✅ hyprlock + hypridle configured |
| Suspend (test + configure) | 🟢 Done | Fix 2 v5 — keyboard ✅, WiFi ✅, audio ✅, Touch Bar ✅ |
| Status bar (quickshell) | 🟠 Medium | Not started |
| Notification daemon (mako) | 🟠 Medium | Not started |
| Browser migration (Brave) | 🟡 Planned | Not started |
| Screenshot tool | 🟢 Nice to have | ✅ Done |
| OSD / HUD bars (swayosd or wob) | 🟢 Nice to have | Not started |
| Wallpaper | 🟢 Nice to have | Not started |
| Cleanup orphaned terminals | 🟢 Nice to have | Not started |
| t2fanrd decision | 🟢 Nice to have | ✅ Done |
