import QtQuick
import qs
import qs.components
import qs.services

// Wi-Fi icon (and network name). Event-driven via `nmcli monitor`, no polling.
Item {
    id: root
    property bool shown: Network.available
    // Set by the pill when it stands vertically on a screen side.
    property bool vertical: false

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Component.onCompleted: Network.watchers++
    Component.onDestruction: Network.watchers--

    Grid {
        id: row
        // One row normally, one column in a vertical pill (left/right side).
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        columnSpacing: 5
        Icon {
            size: 15
            name: Network.wired && Network.ssid === "" ? "desktop" : Network.wifiEnabled ? "wifi" : "wifi-off"
            color: Network.ssid !== "" || Network.wired ? Config.foreground : Config.subtle
        }
        PillText {
            visible: Config.networkShowName && text !== "" && !root.vertical
            text: Network.ssid
            width: Math.min(implicitWidth, 110)
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: Network.openSettings()
    }
}
