import QtQuick
import qs
import qs.components
import qs.services

// Wi-Fi icon (and network name). Event-driven via `nmcli monitor`, no polling.
Item {
    id: root
    property bool shown: Network.available

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Component.onCompleted: Network.watchers++
    Component.onDestruction: Network.watchers--

    Row {
        id: row
        spacing: 5
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            size: 15
            name: Network.wired && Network.ssid === "" ? "desktop" : Network.wifiEnabled ? "wifi" : "wifi-off"
            color: Network.ssid !== "" || Network.wired ? Config.foreground : Config.subtle
        }
        PillText {
            visible: Config.networkShowName && text !== ""
            anchors.verticalCenter: parent.verticalCenter
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
