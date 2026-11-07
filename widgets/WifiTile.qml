import QtQuick
import qs.components
import qs.services

Tile {
    icon: Network.wifiEnabled ? "wifi" : "wifi-off"
    title: "Wi-Fi"
    subtitle: !Network.available ? "nmcli not found" : Network.ssid !== "" ? Network.ssid : !Network.wifiEnabled ? (Network.wired ? "Off · Ethernet" : "Off") : (Network.wired ? "Ethernet" : "Not connected")
    active: Network.wifiEnabled
    onClicked: Network.setWifi(!Network.wifiEnabled)
    onRightClicked: Network.openSettings()

    Component.onCompleted: {
        Network.watchers++;
        Network.refresh();
    }
    Component.onDestruction: Network.watchers--
}
