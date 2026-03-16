# Quickshell Status Bar — Plan

## Goal

Build a minimal Hyprland status bar with quickshell, using an architecture that scales to OSD, notifications, launcher, etc. later.

---

## Architecture

Three-tier layout: **services** (data singletons) → **components** (shared UI primitives) → **modules** (features).

```
quickshell/
  shell.qml                        # Root: ShellRoot, loads bar module
  config/
    qmldir
    Config.qml                     # Singleton — bar height, spacing, font sizes
    Colors.qml                     # Singleton — color palette / theme tokens
  services/
    qmldir                         # Registers all singletons
    Time.qml                       # Singleton — clock
    Audio.qml                      # Singleton — PipeWire wrapper
    Network.qml                    # Singleton — nmcli via Process
    Hypr.qml                       # Singleton — Hyprland IPC helpers
  components/                      # Shared UI building blocks
    qmldir
    PillContainer.qml              # Rounded-rect group wrapper
  modules/
    bar/
      qmldir
      BarWrapper.qml               # Variants (multi-monitor) + PanelWindow
      Bar.qml                      # Pure layout: left / center / right sections
      widgets/
        Clock.qml
        Workspaces.qml
        Battery.qml
        Volume.qml
        Network.qml
        SystemTray.qml
```

### Key patterns

- **Singletons for data**: `Config`, `Colors`, and all services are `pragma Singleton` + registered in `qmldir`. Accessible anywhere, no prop drilling.
- **Multi-monitor**: `BarWrapper.qml` uses `Variants { model: Quickshell.screens }` to stamp one bar per monitor.
- **Layout separation**: `BarWrapper` owns the PanelWindow lifecycle; `Bar.qml` is pure layout.
- **Extensibility**: New widget = one file in `widgets/` + one line in `Bar.qml`. New module (OSD, notifications) = new folder under `modules/`.
- **qmldir manifests**: Every directory with importable types gets a `qmldir` file. This is how QML resolves custom types and singletons.

---

## Build plan — incremental

### Phase 1: Minimal bar (workspaces + clock)

Get something on screen. Validates quickshell install, Hyprland integration, and the config structure.

1. Create `shell.qml` with `ShellRoot` → loads `BarWrapper`
2. Create `config/Config.qml` — bar height (32px), font, padding
3. Create `config/Colors.qml` — small palette (bg, fg, accent, dim)
4. Create `modules/bar/BarWrapper.qml` — `Variants` + `PanelWindow` anchored top
5. Create `modules/bar/Bar.qml` — `RowLayout` with left/center/right sections
6. Create `modules/bar/widgets/Workspaces.qml` — `Repeater` over `Hyprland.workspaces`, highlight active, click to switch
7. Create `modules/bar/widgets/Clock.qml` — `SystemClock` or `Timer`-based time display
8. Add `exec-once = quickshell` to Hyprland config
9. Test: bar visible, workspaces update on switch, clock ticks

### Phase 2: System info (battery + volume + network)

10. Create `services/Audio.qml` — PipeWire default sink volume/mute
11. Create `modules/bar/widgets/Volume.qml` — icon + percentage
12. Create `modules/bar/widgets/Battery.qml` — UPower capacity + charging state
13. Create `services/Network.qml` — `Process` polling `nmcli` for SSID/state
14. Create `modules/bar/widgets/Network.qml` — connected/disconnected + SSID

### Phase 3: Tray + polish

15. Create `modules/bar/widgets/SystemTray.qml` — StatusNotifier items
16. Refine spacing, colors, font sizing
17. Add hover/click interactions where useful (volume scroll, network click)

### Future modules (not in scope now)

- OSD overlays (volume/brightness) — `modules/osd/`
- Notifications — `modules/notifications/` (quickshell can be a notification daemon)
- App launcher — `modules/launcher/`

---

## References

- [Official guide (v0.2.1)](https://quickshell.org/docs/v0.2.1/guide/introduction/)
- [doannc2212/quickshell-config](https://github.com/doannc2212/quickshell-config) — feature-folder pattern
- [tripathiji1312/quickshell](https://github.com/tripathiji1312/quickshell) — full three-tier architecture
- [Tony's bar tutorial](https://www.tonybtw.com/tutorial/quickshell/)
