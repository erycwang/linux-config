# Changes

A running log of changes made to this system — what was added, removed, or modified and why.

---

## 2026-03-14

### Installed `hyprpolkitagent`

- **What**: Polkit authentication agent designed for Hyprland
- **Why**: Provides GUI prompts for privilege escalation (e.g. package installs, system changes) within a Hyprland session. Replaces `polkit-kde-agent` which works but isn't native to the Hyprland ecosystem.
- **Installed from**: `~/src/hyprpolkitagent` (built from source via CMake)
- **Binary**: `/usr/local/libexec/hyprpolkitagent`
- **Service**: `/usr/local/lib/systemd/user/hyprpolkitagent.service` — active, launched at session start by Hyprland (not systemd-enabled)
- **Note**: Logs a non-fatal DBus portal warning on start — does not affect functionality
