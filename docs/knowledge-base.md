# Knowledge Base

Notes on how things work, decisions made, and concepts learned while setting up and maintaining this system.

---

## Systemd: User vs. System Services

Services can run at two levels:

- **System services** (`systemctl ...`) — run as root at boot, before any user session. No display access.
- **User services** (`systemctl --user ...`) — run when you log in, scoped to your session. Have access to Wayland/display.

To check a user service: `systemctl --user status <service>`

## hyprpolkitagent

A polkit authentication agent — provides GUI prompts when an app requests elevated privileges (e.g. package installs, system changes).

**Why it must be a user service**: polkit agents need to render GUI prompts, which requires access to the Wayland socket. System services have no display, so this only works as a user service.

**How it starts**: the service unit exists at `/usr/local/lib/systemd/user/hyprpolkitagent.service` but is `disabled` — systemd does not autostart it. It's launched at session start by Hyprland (likely via `exec-once` in `hyprland.conf`). If you ever change WMs, you'd need to either enable the service or add an equivalent autostart.

**DBus warning on startup**: logs `Failed to register with host portal` — this is non-fatal and doesn't affect functionality.

**Replaces**: `polkit-kde-agent`, which works under Hyprland but isn't native to it.
