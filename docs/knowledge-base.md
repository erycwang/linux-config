# Knowledge Base

Notes on how things work, decisions made, and concepts learned while setting up and maintaining this system.

---

## Systemd: User vs. System Services

Services can run at two levels:

- **System services** (`systemctl ...`) — run as root at boot, before any user session. No display access.
- **User services** (`systemctl --user ...`) — run when you log in, scoped to your session. Have access to Wayland/display.

To check a user service: `systemctl --user status <service>`

## Debugging suspend/resume WiFi issues

Useful commands for diagnosing brcmfmac / WiFi failures after resume:

```bash
# Suspend fix service logs (current boot)
journalctl -b -u suspend-fix-t2.service --no-pager

# Kernel logs for WiFi driver and PCI power events
journalctl -b -k -g "brcmfmac|D3cold|pci.*rescan|pci.*remove" --no-pager

# iwd logs — check if Wiphy was detected after resume
journalctl -b -u iwd --no-pager

# NetworkManager logs
journalctl -b -u NetworkManager --no-pager

# Use -b -1, -b -2 etc. to check previous boots
```

**What to look for:**
- `Unable to change power state from D3cold to D0` — PCIe device stuck, needs PCI remove/rescan
- `brcmf_pcie_probe: failed` — brcmfmac loaded but couldn't talk to hardware
- `registered new interface driver brcmfmac` with **no** `enabling device` or firmware version after it — module loaded but no PCI device present to probe
- iwd showing only `Network configuration is disabled` with no `Wiphy:` line — no WiFi hardware visible

## `udevadm settle` vs `sleep` after modprobe

`udevadm settle` waits until all pending udev events are processed — useful for waiting on hardware init after modprobe or PCI rescan. But it only works when the operation queues events synchronously.

**Works with `udevadm settle`:**
- `modprobe brcmfmac` — firmware load is synchronous, udev events fire before modprobe returns
- `echo 1 > /sys/bus/pci/rescan` — PCI enumeration queues events synchronously
- `ip link set ... down`, `rfkill block` — state changes queue events immediately

**Requires fixed `sleep`:**
- `modprobe apple-bce` — triggers USB enumeration asynchronously through the T2 virtual USB bus. The modprobe returns after the kernel module loads and the handshake completes, but USB devices (keyboard, trackpad, Touch Bar) enumerate over ~2 seconds afterward. `udevadm settle` returns immediately because no events are queued yet.

## Brave browser window management on Hyprland

### How Brave opens file managers
Brave does **not** use `xdg-open` for "Show in folder" — it uses the `org.freedesktop.FileManager1` DBus interface (`ShowItems` method) directly. On a system with Dolphin installed, Brave finds and calls Dolphin via DBus, bypassing `xdg-mime` settings entirely. Changing `xdg-mime default inode/directory` has no effect on this behavior.

### Floating Brave dialogs with windowrules
Brave uses two different window classes:
- `brave-browser` — normal browser windows/tabs
- `brave` — native dialogs (e.g. "site wants to save", permission prompts)

To float the save/permission dialogs:
```
windowrule {
    name = brave-save
    match:class = ^(brave)$
    match:title = .*wants to save.*

    float = yes
    center = yes
    size = 600 400
}
```

### Hyprland windowrule: regex not glob
`match:title` and `match:class` use **regex**, not glob. `*foo*` is invalid — use `.*foo.*` for substring matching. Without anchors, Hyprland may or may not do partial matching depending on version — always use `.*` explicitly for safety.

## hyprpolkitagent

A polkit authentication agent — provides GUI prompts when an app requests elevated privileges (e.g. package installs, system changes).

**Why it must be a user service**: polkit agents need to render GUI prompts, which requires access to the Wayland socket. System services have no display, so this only works as a user service.

**How it starts**: the service unit exists at `/usr/local/lib/systemd/user/hyprpolkitagent.service` but is `disabled` — systemd does not autostart it. It's launched at session start by Hyprland (likely via `exec-once` in `hyprland.conf`). If you ever change WMs, you'd need to either enable the service or add an equivalent autostart.

**DBus warning on startup**: logs `Failed to register with host portal` — this is non-fatal and doesn't affect functionality.

**Replaces**: `polkit-kde-agent`, which works under Hyprland but isn't native to it.
