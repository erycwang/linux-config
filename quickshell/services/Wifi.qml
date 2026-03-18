pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string ssid: ""
    property int signal: 0
    property bool connected: false

    property var proc: Process {
        command: ["nmcli", "-t", "-f", "active,ssid,signal", "dev", "wifi"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("yes:")) {
                    let parts = line.split(":")
                    root.ssid = parts[1]
                    root.signal = parseInt(parts[2]) || 0
                    root.connected = true
                }
            }
        }
        onExited: {
            if (!root.connected) {
                root.ssid = ""
                root.signal = 0
            }
        }
    }

    property var timer: Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.connected = false
            proc.running = true
        }
    }
}
