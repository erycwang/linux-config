import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    property var screen  // ShellScreen passed from Bar
    spacing: 4

    Repeater {
        model: 9
        delegate: Rectangle {
            required property int index
            property int wsId: index + 1
            property bool isActive: Hyprland.monitorFor(screen)?.activeWorkspace?.id === wsId
            property bool isOnOtherMonitor: Hyprland.monitors.values.some(
                m => m !== Hyprland.monitorFor(screen) && m.activeWorkspace?.id === wsId
            )
            // has windows but not currently displayed on any monitor
            property bool hasOffscreenWindows: !isActive && !isOnOtherMonitor
                && Hyprland.workspaces.values.some(ws => ws.id === wsId)

            width: 24
            height: 24
            radius: 4
            color: isActive ? "#cdd6f4" : "transparent"
            border.width: isOnOtherMonitor ? 1 : 0
            border.color: isOnOtherMonitor ? "#6c7086" : "transparent"

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: parent.hasOffscreenWindows ? -2 : 0
                text: parent.wsId
                color: parent.isActive ? "#1e1e2e" : "#6c7086"
                font.pixelSize: 12
                font.family: "monospace"
            }

            // Dot pip: workspace has windows but isn't visible on any monitor
            Rectangle {
                visible: parent.hasOffscreenWindows
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
                width: 4
                height: 4
                radius: 2
                color: "#6c7086"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + parent.wsId)
            }
        }
    }
}
