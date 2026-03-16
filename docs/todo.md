# Setup To-Do

Gaps and planned changes to the current system setup, ordered by priority.

---

## Priority 1 — Security & Power (do these first)

### Keyring daemon (gnome-keyring)

**GitHub CLI credentials are currently stored in plaintext** at `~/.config/gh/hosts.yml`. No Secret Service keyring daemon is running.

- Install `gnome-keyring` and `libsecret`: `sudo pacman -S gnome-keyring libsecret`
- Add to Hyprland config: `exec-once = gnome-keyring-daemon --start --components=secrets`
- Wipe plaintext credentials and reauth: `rm ~/.config/gh/hosts.yml && gh auth login`

**Why this is Priority 1**: GitHub token sitting in plaintext is a security gap.

---

### Lock screen + idle daemon

**Status bar has no lock screen and no idle management configured.**

- Install `hyprlock` — Hyprland-native screen locker
- Install `hypridle` — Hyprland-native idle daemon (replaces unused `kidletime`)
- Configure `hypridle` with a chain:
  1. Dim screen after N minutes
  2. Lock with `hyprlock` after M minutes
  3. Suspend after P minutes (calls `systemctl suspend`)
- Wire `hyprlock` into the Hyprland keybind (e.g. `Super+L`)
- Remove `kidletime` if it's no longer needed as a dependency

**Why this is #1**: No lock screen is a security gap. Suspend also depends on this — without `hypridle`, suspend won't trigger automatically on idle.

---

### Suspend

**Hardware**: 2020 MacBook Pro 13" (4x Thunderbolt, Touch Bar) — T2 chip, Intel Ice Lake i915, kernel 6.19.7-1-cachyos

**Background**: The t2linux wiki confirms suspend is partially broken on all T2 Macs — a firmware change shipped with macOS Sonoma broke S3 deep sleep at the firmware level. The `apple-bce` (T2 bridge) driver is the primary culprit; suspend works when it's unloaded. See [t2linux wiki](https://wiki.t2linux.org/guides/postinstall/), [T2Linux-Suspend-Fix](https://github.com/deqrocks/T2Linux-Suspend-Fix), and [Omarchy issue #1840](https://github.com/basecamp/omarchy/issues/1840).

- ~~Verify `systemctl suspend` works cleanly on T2 hardware~~ — root cause found: `brcmfmac` WiFi driver times out on suspend, and `deep` sleep never resumes
  - **Partial fix already in place**: `/usr/lib/systemd/system-sleep/wifi-sleep` tries to unload/reload the WiFi driver around sleep, but it fails because `brcmfmac` is still in use by NetworkManager at the time it runs

#### Fix 1 — Switch from `deep` to `s2idle` sleep

[OPTIONAL - we seem to be able to reboot from deep sleep as long as we unload the drivers] S3 deep sleep is broken at the firmware level (since macOS Sonoma). Switch to s2idle:

- Add `mem_sleep_default=s2idle` to kernel parameters in `/etc/default/limine`:
  ```
  KERNEL_CMDLINE[default]+="... mem_sleep_default=s2idle"
  ```
  Then regenerate: `sudo limine-mkconfig -o /boot/limine/limine.conf` (or however CachyOS regenerates Limine config)
- Also set in `/etc/systemd/sleep.conf`:
  ```ini
  [Sleep]
  SuspendState=freeze
  MemorySleepMode=s2idle
  ```
- **Test without rebooting**: `echo s2idle | sudo tee /sys/power/mem_sleep && systemctl suspend`
- Trade-off: `s2idle` uses more battery than true S3 (CPU stays in low-power idle rather than fully powering down)


#### Fix 2 — Unload T2 and WiFi modules around suspend ✅ Done (v4)

`/etc/systemd/system/suspend-fix-t2.service` deployed and enabled.

**v1 issue (2026-03-15)**: `rmmod brcmfmac` failed with "Resource temporarily unavailable" because NetworkManager held the device. Service failed, so `ExecStop` never ran — `apple-bce` stayed unloaded on resume, leaving keyboard/trackpad dead.

**v2 issue**: Stopping NetworkManager alone wasn't enough — `rmmod brcmfmac` still failed with "Resource temporarily unavailable" because the device wasn't fully released. WiFi stayed loaded through suspend and failed to communicate with the chip on resume (`timed out waiting for txstatus`). Touch Bar also didn't resume (modules weren't managed).

**v3 fix**: Added `rfkill block wifi` to force-release the device, a 1s settle delay before rmmod, separate rmmod lines so one failure doesn't skip others. Also added Touch Bar modules (`hid_appletb_kbd`, `hid_appletb_bl`) and a 2s delay on resume to let `apple-bce` initialize before reloading dependent modules.

**v3 result (2026-03-15)**: Keyboard/Touch Bar now work after resume ✅. WiFi still fails — `rmmod brcmfmac` kept getting "Resource temporarily unavailable" because the kernel network interface (`wlan0`) remained up and held a module reference count, even after NM stop + rfkill.

**v4 fix (2026-03-15)**: Added `ip link set wlan0 down` between rfkill and rmmod to release the kernel interface reference. Also added `rmmod -f brcmfmac brcmfmac_wcc` on the resume side before `modprobe brcmfmac` as a safety net — if pre-suspend rmmod still fails, this clears the stale broken module before a clean reload. Added 1s delay after modprobe before starting NetworkManager.

```ini
[Unit]
Description=Fix T2 suspend (unload apple-bce + WiFi modules)
Before=sleep.target
StopWhenUnneeded=yes

[Service]
User=root
Type=oneshot
RemainAfterExit=yes
ExecStart=-/usr/bin/systemctl stop NetworkManager
ExecStart=-/usr/bin/rfkill block wifi
ExecStart=-/usr/bin/ip link set wlan0 down
ExecStart=-/usr/bin/sleep 1
ExecStart=-/usr/bin/rmmod -f brcmfmac brcmfmac_wcc
ExecStart=-/usr/bin/rmmod -f hid_appletb_kbd hid_appletb_bl
ExecStart=-/usr/bin/rmmod -f apple-bce
ExecStop=/usr/bin/modprobe apple-bce
ExecStop=/usr/bin/sleep 2
ExecStop=/usr/bin/modprobe hid_appletb_bl
ExecStop=/usr/bin/modprobe hid_appletb_kbd
ExecStop=/usr/bin/rfkill unblock wifi
ExecStop=-/usr/bin/rmmod -f brcmfmac brcmfmac_wcc
ExecStop=/usr/bin/modprobe brcmfmac
ExecStop=/usr/bin/sleep 1
ExecStop=/usr/bin/systemctl start NetworkManager

[Install]
WantedBy=sleep.target
```

After enabling, remove or disable the old wifi-sleep script to avoid conflicts:
`sudo rm /usr/lib/systemd/system-sleep/wifi-sleep` (note: may be recreated by package updates)

#### Fix 3 — Touch Bar module management ✅ Merged into Fix 2 v3

Touch Bar modules (`hid_appletb_kbd`, `hid_appletb_bl`) are now managed by `suspend-fix-t2.service` — see v3 above.
- If `tiny-dfr` is installed later, also add `systemctl stop/start tiny-dfr` around suspend

#### Fix 4 — Disable ACPI wakeup sources that cause spurious wakes

Currently `XHC1` (USB) and `ARPT` (WiFi) are enabled as S3 wakeup sources in `/proc/acpi/wakeup`. Per the [ArchWiki](https://wiki.archlinux.org/title/Mac/Troubleshooting), these can cause the system to wake immediately after suspend. Create a systemd service or tmpfiles rule to disable them:

```bash
echo XHC1 | sudo tee /proc/acpi/wakeup  # toggles off
echo ARPT | sudo tee /proc/acpi/wakeup  # toggles off
```

To persist across reboots, create `/etc/systemd/system/disable-wakeup.service` or add to an existing boot script.

#### Fix 5 (if needed) — Thunderbolt power management

The [ArchWiki](https://wiki.archlinux.org/title/Mac/Troubleshooting) suggests adding `acpi_osi=!Darwin` to the kernel cmdline to prevent Thunderbolt adapters from staying active during sleep (can reduce power draw by ~2W and avoid slow wakeups).

#### Not needed for this model

- `pcie_ports=native pcie_aspm=off` — only needed for models with a discrete GPU
- `i915.enable_psr=0` — no i915 errors in current logs; try only if display issues persist after the above fixes

#### Testing checklist

- [ ] Suspend via `systemctl suspend` — screen comes back on resume
- [ ] WiFi reconnects after resume
- [ ] Audio works after resume
- [ ] Touch Bar works after resume
- [ ] Lid close triggers suspend, lid open resumes
- [ ] No spurious immediate wakeups
- [ ] Resume time is acceptable (up to 30 seconds can be normal on T2 due to ibridge/smpboot delays)

**Why this is high priority**: Laptop without working suspend drains battery and overheats when closed.

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
- Running on defaults: linear curve, 55°C–75°C, 1350–6864 RPM
- Create `/etc/t2fand.conf` if custom fan curve is needed

---

## Summary table

| Item | Priority | Status |
|---|---|---|
| Keyring daemon (gnome-keyring) | 🔴 High | Not started — gh token in plaintext |
| Lock screen (hyprlock + hypridle) | 🔴 High | Not started |
| Suspend (test + configure) | 🔴 High | Fix 2 v4 deployed (keyboard ✅, WiFi testing) |
| Status bar (quickshell) | 🟠 Medium | Not started |
| Notification daemon (mako) | 🟠 Medium | Not started |
| Browser migration (Brave) | 🟡 Planned | Not started |
| Screenshot tool | 🟢 Nice to have | ✅ Done |
| Wallpaper | 🟢 Nice to have | Not started |
| Cleanup orphaned terminals | 🟢 Nice to have | Not started |
| t2fanrd decision | 🟢 Nice to have | ✅ Done |
