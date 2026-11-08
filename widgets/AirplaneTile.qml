import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.components
import qs.services

Tile {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: !Network.wifiEnabled && !(adapter && adapter.enabled)

    icon: "airplane"
    title: "Airplane Mode"
    subtitle: on ? "On" : "Off"
    active: on
    onClicked: {
        const enable = !on;
        Quickshell.execDetached(["nmcli", "radio", "all", enable ? "off" : "on"]);
        Network.wifiEnabled = !enable;
        if (adapter)
            adapter.enabled = !enable;
    }
    Component.onCompleted: Network.refresh()
}
