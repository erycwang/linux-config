pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool   valid:       false
    property int    temperature: 0
    property int    weatherCode: 0
    property string icon:        "\ue318"
    property string city:        ""
    property string _raw:        ""
    property real   _lastTime:   0

    function codeToIcon(code) {
        if (code === 113) return "\ue30d"
        if (code === 116) return "\ue302"
        if (code === 119 || code === 122) return "\ue318"
        if (code === 143 || code === 248 || code === 260) return "\ue313"
        if (code === 176 || code === 263 || code === 266 ||
            code === 293 || code === 296) return "\ue314"
        if ((code >= 299 && code <= 308) || code === 356) return "\ue319"
        if (code === 200 || code === 386 || code === 389) return "\ue31c"
        if (code >= 323 && code <= 338) return "\ue31a"
        return "\ue318"
    }

    property var proc: Process {
        // Requires: curl, jq
        command: ["sh", "-c",
            "city=$(curl -s --max-time 5 'https://wttr.in/?format=%l') && " +
            "curl -s --max-time 10 'https://wttr.in/?format=j1' | " +
            "jq -r --arg city \"$city\" '[.data.current_condition[0].temp_C, .data.current_condition[0].weatherCode, $city] | join(\"|\")'"]
        stdout: StdioCollector {
            onStreamFinished: root._raw = this.text.trim()
        }
        onExited: (exitCode, _) => {
            if (exitCode !== 0 || root._raw === "") {
                root._raw = ""
                root.valid = false
                return
            }
            let parts = root._raw.split("|")
            root._raw = ""
            if (parts.length < 3) { root.valid = false; return }
            let t = parseInt(parts[0])
            let c = parseInt(parts[1])
            if (isNaN(t) || isNaN(c)) { root.valid = false; return }
            root.temperature = t
            root.weatherCode = c
            root.icon        = root.codeToIcon(c)
            root.city        = parts[2].trim()
            root.valid       = true
        }
    }

    property var timer: Timer {
        interval:         60000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            let now = Date.now()
            // On first run or after suspend (time jump > 2 min), refresh immediately
            if (root._lastTime === 0 || (now - root._lastTime) > 120000) {
                proc.running = true
            }
            root._lastTime = now
        }
    }

    property var fullRefreshTimer: Timer {
        interval:         900000  // 15 min
        running:          true
        repeat:           true
        onTriggered:      proc.running = true
    }
}
