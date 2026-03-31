pragma Singleton
import QtQuick

QtObject {
    property bool open: false
    property var popupScreen: null

    function toggle(screen) {
        if (open && popupScreen === screen) {
            open = false
        } else {
            popupScreen = screen
            open = true
        }
    }

    function close() { open = false }
}
