pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string ssid: ""
    property int signal: 0
    property bool connected: false

    // Staging properties — updated during parse, applied atomically on exit
    property string _nextSsid: ""
    property int _nextSignal: 0
    property bool _nextConnected: false

    property var proc: Process {
        command: ["nmcli", "-t", "-f", "active,ssid,signal", "dev", "wifi"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("yes:")) {
                    let parts = line.split(":")
                    root._nextSsid = parts[1]
                    root._nextSignal = parseInt(parts[2]) || 0
                    root._nextConnected = true
                }
            }
        }
        onExited: {
            root.ssid = root._nextConnected ? root._nextSsid : ""
            root.signal = root._nextConnected ? root._nextSignal : 0
            root.connected = root._nextConnected
            root._nextSsid = ""
            root._nextSignal = 0
            root._nextConnected = false
        }
    }

    property var timer: Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            proc.running = true
        }
    }
}
