# Phase 1: Bar with Clock

Minimal viable bar — validates the scaffold, Hyprland integration, and multi-monitor setup. No theming, no services, no workspace widgets yet.

---

## File structure

```
quickshell/
  shell.qml
  modules/
    bar/
      BarWrapper.qml
      Bar.qml
      widgets/
        Clock.qml
```

No `qmldir` files needed at this scale.

### Import structure

QML only auto-imports `UpperCase.qml` files from the **same directory**. Subdirectories need explicit relative imports. Imports are not global or inherited — each file declares only what it directly uses:

```
shell.qml              → import "modules/bar"      (to find BarWrapper)
modules/bar/Bar.qml    → import "widgets"           (to find Clock)
widgets/Clock.qml      → (no custom imports)
```

As we add tiers, each file imports its own dependencies:
```
modules/bar/Bar.qml    → import "../../services"    (when Audio/Network exist)
                       → import "../../components"   (when PillContainer exists)
```

---

## Step 1 — Create directories

```bash
mkdir -p ~/Projects/linux-config/quickshell/modules/bar/widgets
```

---

## Step 2 — `shell.qml`

`~/Projects/linux-config/quickshell/shell.qml`

```qml
import Quickshell
import "modules/bar"  // QML only auto-imports UpperCase.qml from the same directory.
                      // Subdirectories need an explicit relative import.
                      // Each file imports only what it directly uses — imports are
                      // not inherited or global. Bar.qml will import "widgets" itself.

// ShellRoot is the required top-level element for every quickshell config.
// It extends Scope and adds lifecycle management + a settings property.
ShellRoot {
    BarWrapper {}
}
```

---

## Step 3 — `BarWrapper.qml`

`~/Projects/linux-config/quickshell/modules/bar/BarWrapper.qml`

```qml
import Quickshell

// Variants instantiates its delegate once per item in model.
// Quickshell.screens is a live list of connected monitors —
// adding/removing a display automatically creates/destroys a bar.
Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            // modelData is injected by Variants for each instance.
            // We must declare it explicitly — PanelWindow doesn't have it by default.
            // It holds the ShellScreen object for this monitor.
            property var modelData

            // Assign this window to the correct monitor.
            screen: modelData

            // Dock to the top edge spanning full width.
            // This also sets exclusiveZone automatically so windows
            // don't overlap the bar.
            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 32   // bar height in pixels
            color: "#1e1e2e"     // hardcoded for now (Catppuccin Mocha base)

            Bar {}
        }
    }
}
```

---

## Step 4 — `Bar.qml`

`~/Projects/linux-config/quickshell/modules/bar/Bar.qml`

```qml
import QtQuick
import QtQuick.Layouts
import "widgets"  // relative import — QML looks for UpperCase.qml files in ./widgets/
                  // gives us access to Clock (and future Workspaces, Volume, etc.)

// Item is an invisible container — fills the PanelWindow.
Item {
    anchors.fill: parent

    // RowLayout arranges children horizontally.
    // Children use Layout.* attached properties to control sizing.
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        // Layout.fillWidth: true makes this item expand to fill remaining space.
        // Two of these (left + right) act as spacers, pushing Clock to center.
        Item {
            Layout.fillWidth: true  // left spacer — workspaces go here in Phase 2
        }

        Clock {}  // center

        Item {
            Layout.fillWidth: true  // right spacer — system info goes here in Phase 3
        }
    }
}
```

---

## Step 5 — `Clock.qml`

`~/Projects/linux-config/quickshell/modules/bar/widgets/Clock.qml`

```qml
import Quickshell
import QtQuick

// Text is the root element — the clock widget is just a styled text label.
Text {
    // SystemClock is a non-visual child that tracks system time.
    // It lives inside Text because it belongs to this widget, not to Bar.
    SystemClock {
        id: clock
        // Precision controls how often the clock updates.
        // Minutes = once per minute (better for battery).
        // Change to SystemClock.Seconds to show seconds.
        precision: SystemClock.Minutes
    }

    // clock.date is a QML Date object — use this, not new Date().
    // new Date() is evaluated once at binding creation and won't update.
    // clock.date is a reactive property that changes each tick.
    text: Qt.formatTime(clock.date, "HH:mm")  // "HH:mm" = 24h, "h:mm AP" = 12h

    color: "#cdd6f4"        // hardcoded for now (Catppuccin text color)
    font.pixelSize: 13
    font.family: "monospace"
}
```

**To show seconds:**
```qml
precision: SystemClock.Seconds
text: Qt.formatTime(clock.date, "HH:mm:ss")
```

---

## Step 6 — Wire into Hyprland

Add to `~/.config/hypr/hyprland.conf` in the `### AUTOSTART ###` section:

```conf
exec-once = quickshell
```

Quickshell auto-loads `~/.config/quickshell/shell.qml` — no path argument needed.

---

## Step 7 — Test

**Run without restarting Hyprland:**
```bash
quickshell
```

Bar should appear at the top of every monitor. Kill with `Ctrl+C`.

**Check errors:**
```bash
quickshell 2>&1 | head -50
```

**Live reload** — with quickshell running, save any `.qml` file and it reloads in ~1s automatically.

### Common errors

| Error | Cause | Fix |
|---|---|---|
| `file not found: BarWrapper` | Wrong path or filename not uppercase | `ls ~/Projects/linux-config/quickshell/modules/bar/` |
| `Cannot assign to non-existent property "screen"` | Old quickshell version | `quickshell --version` — need v0.2.x |
| Bar on only one monitor | Variants not picking up screens | Add `Component.onCompleted: console.log(Quickshell.screens)` to debug |
| Bar overlaps windows | Anchors not set | Make sure `anchors { top: true; left: true; right: true }` |

---

## Checklist

- [ ] Bar appears on all monitors
- [ ] Clock shows correct time in HH:mm
- [ ] Save a `.qml` file → bar reloads without restart
- [ ] Bar does not overlap app windows
- [ ] Clock updates each minute
