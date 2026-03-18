import Quickshell
import "../../config"

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        property var modelData  // ShellScreen injected by Variants for this instance

        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: Config.barHeight
        color: Qt.rgba(0x1e/255, 0x1e/255, 0x2e/255, 0.95)

        Bar { screen: modelData }
    }
}
