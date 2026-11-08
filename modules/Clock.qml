import QtQuick
import Quickshell
import qs
import qs.components

// Clock + date, e.g. "14:32  Sat 7 Nov".
Item {
    id: root

    // Every module has `shown`; when false it takes no space in the pill.
    property bool shown: true
    // Set by the pill when it stands vertically on a screen side.
    property bool vertical: false

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // Ticks once a minute, and only while the pill is visible.
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        enabled: root.visible
    }

    Grid {
        id: row
        // One row normally, one column in a vertical pill (left/right side).
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        columnSpacing: 8

        PillText {
            text: Qt.formatDateTime(clock.date, Config.timeFormat)
            font.weight: Font.DemiBold
        }
        PillText {
            visible: Config.showDate
            text: Qt.formatDateTime(clock.date, root.vertical ? "ddd d" : Config.dateFormat)
            color: Config.subtle
            sizeFactor: root.vertical ? 0.8 : 1
        }
    }
}
