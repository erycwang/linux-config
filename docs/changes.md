# Changes

A running log of changes made to this system — what was added, removed, or modified and why.

---

## 2026-03-15

### Updated `suspend-fix-t2.service` to v4

- **What**: Added `ip link set wlan0 down` pre-suspend and force-reload safety net on resume
- **Why**: v3's `rmmod brcmfmac` was still failing with "Resource temporarily unavailable" — rfkill + NM stop left the kernel interface up, holding a module reference count. v3 result: keyboard/Touch Bar ✅, WiFi still dead on resume.
- **Changes in v4**:
  - Added `ip link set wlan0 down` between rfkill and rmmod — releases the kernel interface reference that was blocking rmmod
  - Added `rmmod -f brcmfmac brcmfmac_wcc` on resume (before modprobe) as safety net — if pre-suspend rmmod fails, this clears the stale broken module before a clean reload
  - Added 1s delay after modprobe before starting NetworkManager
- **Deploy**: `sudo cp ~/Projects/linux-config/suspend-fix-t2.service /etc/systemd/system/ && sudo systemctl daemon-reload`

---

### Updated `suspend-fix-t2.service` to v3

- **What**: Rewrote suspend service to fix WiFi and Touch Bar not resuming after suspend
- **Why**: v2's `rmmod brcmfmac` still failed ("Resource temporarily unavailable") despite stopping NetworkManager — the device wasn't fully released. WiFi chip was unresponsive on resume (`timed out waiting for txstatus`). Touch Bar also didn't resume.
- **Changes in v3**:
  - Added `rfkill block wifi` before rmmod to force-release the WiFi device
  - Added 1s settle delay before rmmod
  - Separate rmmod lines so one failure doesn't skip others
  - Added Touch Bar modules (`hid_appletb_kbd`, `hid_appletb_bl`) — unloaded on suspend, reloaded on resume
  - Added 2s delay on resume to let `apple-bce` initialize before reloading dependent modules
  - Added `rfkill unblock wifi` on resume before reloading brcmfmac
- **Deploy**: `sudo cp ~/Projects/linux-config/suspend-fix-t2.service /etc/systemd/system/ && sudo systemctl daemon-reload`

---

### Installed `hyprshot` and bound screenshot key

- **What**: Installed `hyprshot` (AUR); bound `Super+Shift+X` → `hyprshot -m region` in `hyprland.conf`
- **Why**: No screenshot capability was previously installed
- **Keybind**: `$mainMod SHIFT, X` — region selection screenshot

---

### Enabled `t2fanrd` fan control daemon

- **What**: Enabled `t2fanrd` systemd service (`systemctl enable --now t2fanrd`)
- **Why**: T2 Macs need an explicit daemon to control fan speed under Linux; without it the fan runs unmanaged
- **Config**: No `/etc/t2fand.conf` created — running on defaults (linear curve, 55°C–75°C, 1350–6864 RPM)
- **Status**: Active and enabled on boot

---

### Added WiFi suspend hook

- **What**: Created `/usr/lib/systemd/system-sleep/wifi-sleep`
- **Why**: T2 Mac's `brcmfmac` WiFi driver times out during suspend, causing a blank screen on resume. Unloading it before suspend and reloading after fixes the issue.
- **How**: systemd runs all executable scripts in `/usr/lib/systemd/system-sleep/` on sleep/wake. The script unloads `brcmfmac` on `pre` (suspend) and reloads it on `post` (resume).
- **Made executable**: `sudo chmod +x /usr/lib/systemd/system-sleep/wifi-sleep`

---

### Configured `sddm.conf` for Wayland

- **What**: Created/edited `/etc/sddm.conf` with Wayland-specific settings
- **Why**: Ensures SDDM runs its greeter natively on Wayland and autologs into Hyprland
- **Settings**:
  - `Session=hyprland` — autologin directly into Hyprland
  - `DisplayServer=wayland` — SDDM greeter uses Wayland backend instead of X11
  - `GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell` — allows Qt greeter UI to use the Wayland layer-shell protocol so it displays correctly
---

### Installed `markview.nvim`

- **What**: Markdown rendering plugin for Neovim
- **Why**: Improves readability of markdown files directly in the editor — renders headings, tables, code blocks, etc. visually
- **Installed via**: lazy.nvim (`~/.config/nvim/lua/plugins/markview.lua`)
- **Config**: `lazy = false` (lazy-loading not recommended per upstream docs)
- **Note**: Works with Neovim's built-in tree-sitter; no additional parser plugin needed

---

## 2026-03-14

### Installed `hyprpolkitagent`

- **What**: Polkit authentication agent designed for Hyprland
- **Why**: Provides GUI prompts for privilege escalation (e.g. package installs, system changes) within a Hyprland session. Replaces `polkit-kde-agent` which works but isn't native to the Hyprland ecosystem.
- **Installed from**: `~/src/hyprpolkitagent` (built from source via CMake)
- **Binary**: `/usr/local/libexec/hyprpolkitagent`
- **Service**: `/usr/local/lib/systemd/user/hyprpolkitagent.service` — active, launched at session start by Hyprland (not systemd-enabled)
- **Note**: Logs a non-fatal DBus portal warning on start — does not affect functionality
