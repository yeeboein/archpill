import QtQuick
import Quickshell
import qs
import qs.components

// Clock + date, e.g. "14:32  Sat 7 Nov".
Item {
    id: root

    // Every module has `shown`; when false it takes no space in the pill.
    property bool shown: true

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // Ticks once a minute, and only while the pill is visible.
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        enabled: root.visible
    }

    Row {
        id: row
        spacing: 8

        PillText {
            text: Qt.formatDateTime(clock.date, Config.timeFormat)
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
        PillText {
            visible: Config.showDate
            text: Qt.formatDateTime(clock.date, Config.dateFormat)
            color: Config.subtle
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
