import QtQuick
import Quickshell
import qs
import qs.components

Card {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    Column {
        width: parent.width
        PillText {
            text: Qt.formatDateTime(clock.date, Config.timeFormat)
            sizeFactor: 2.2
            font.weight: Font.Bold
        }
        PillText {
            text: Qt.formatDateTime(clock.date, "dddd d MMMM yyyy")
            color: Config.subtle
        }
    }
}
