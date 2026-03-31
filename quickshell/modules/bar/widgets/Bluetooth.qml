import QtQuick
import Quickshell.Bluetooth
import "../../../config"

Item {
    id: root
    signal clicked()

    property int connectedCount: {
        let count = 0
        for (const d of Bluetooth.devices.values) {
            if (d.connected) count++
        }
        return count
    }

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: root.connectedCount > 0 ? "BT" + ": "+ root.connectedCount : "BT"
        color: root.connectedCount > 0 ? Colors.accent : Colors.muted
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
