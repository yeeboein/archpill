import QtQuick
import Quickshell.Bluetooth
import qs
import qs.components

// Bluetooth icon while Bluetooth is on; number of connected devices.
Item {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int connected: adapter ? adapter.devices.values.filter(d => d.connected).length : 0
    property bool shown: !!adapter && adapter.enabled
    // Set by the pill when it stands vertically on a screen side.
    property bool vertical: false

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Grid {
        id: row
        // One row normally, one column in a vertical pill (left/right side).
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        columnSpacing: 3
        Icon {
            size: 15
            name: "bluetooth"
            color: root.connected > 0 ? Config.accent : Config.foreground
        }
        PillText {
            visible: root.connected > 1
            text: root.connected
            sizeFactor: 0.85
        }
    }
}
