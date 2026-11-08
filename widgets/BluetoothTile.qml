import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.components
import qs.services

Tile {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: !!adapter && adapter.enabled
    readonly property var connectedNames: {
        if (!adapter)
            return [];
        const out = [];
        const devs = adapter.devices.values;
        for (let i = 0; i < devs.length; i++)
            if (devs[i].connected)
                out.push(devs[i].name || devs[i].deviceName);
        return out;
    }

    icon: on ? "bluetooth" : "bluetooth-off"
    title: "Bluetooth"
    subtitle: !adapter ? "No adapter" : !on ? "Off" : connectedNames.length > 0 ? connectedNames.join(", ") : "On"
    active: on
    onClicked: if (adapter) adapter.enabled = !adapter.enabled
    hasDetails: true
    onDetailsRequested: PillState.ccPage = "bluetooth"
    onRightClicked: Desktop.run("btsettings")
}
