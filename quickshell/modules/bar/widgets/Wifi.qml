import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../config"

RowLayout {
    spacing: 4

    Text {
        text: {
            if (!Wifi.connected) return "xxxx"
            let s = Wifi.signal
            let b1 = s >= 25 ? "▂" : "░"
            let b2 = s >= 50 ? "▄" : "░"
            let b3 = s >= 75 ? "▆" : "░"
            let b4 = s >= 90 ? "█" : "░"
            return b1 + b2 + b3 + b4
        }
        color: Wifi.connected ? "#cdd6f4" : "#f38ba8"
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
    }

    Text {
        text: {
            if (!Wifi.connected) return "NO NETWORK"
            let name = Wifi.ssid
            return name.length > 12 ? name.substring(0, 12) + "…" : name
        }
        color: Wifi.connected ? "#cdd6f4" : "#f38ba8"
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
    }
}
