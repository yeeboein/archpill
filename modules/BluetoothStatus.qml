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

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 3
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            size: 15
            name: "bluetooth"
            color: root.connected > 0 ? Config.accent : Config.foreground
        }
        PillText {
            visible: root.connected > 1
            anchors.verticalCenter: parent.verticalCenter
            text: root.connected
            sizeFactor: 0.85
        }
    }
}
