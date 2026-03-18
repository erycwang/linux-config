import Quickshell
import QtQuick

Text {
	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}
	text: Qt.formatTime(clock.date, "HH:mm") 
	color: "white"

	font.pixelSize: 12
	font.family: "monospace"

}
