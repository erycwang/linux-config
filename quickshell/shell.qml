import Quickshell
import "modules/bar"  // QML only auto-imports UpperCase.qml from the same directory.
                      // Subdirectories need an explicit relative import.

ShellRoot {
    BarWrapper {}
}
