import QtQuick
import Quickshell.Bluetooth
import qs
import qs.components
import qs.services

// Bluetooth menu inside the control centre: on/off, scan, connect, pair, forget.
Column {
    id: page
    spacing: 8

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: {
        if (!adapter)
            return [];
        const list = adapter.devices.values.filter(d => d && (d.paired || d.connected || (d.name && d.name !== d.address)));
        return list.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || String(a.name).localeCompare(String(b.name)));
    }

    // stop scanning when the menu closes
    Component.onDestruction: if (adapter && adapter.discovering) adapter.discovering = false

    Rectangle {
        width: parent.width
        height: 50
        radius: 14
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
        PillText {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            text: !page.adapter ? "No Bluetooth adapter" : page.adapter.enabled ? "Bluetooth is on" : "Bluetooth is off"
            font.weight: Font.DemiBold
        }
        Switch {
            visible: !!page.adapter
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: !!page.adapter && page.adapter.enabled
            onToggled: v => page.adapter.enabled = v
        }
    }

    Item {
        width: parent.width
        height: 26
        visible: !!page.adapter && page.adapter.enabled
        PillText {
            anchors.verticalCenter: parent.verticalCenter
            text: page.adapter && page.adapter.discovering ? "Searching for devices…" : "Devices"
            color: Config.subtle
            sizeFactor: 0.85
        }
        SmallChip {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            label: page.adapter && page.adapter.discovering ? "Stop" : "Search"
            onClicked: page.adapter.discovering = !page.adapter.discovering
        }
    }

    Repeater {
        model: page.adapter && page.adapter.enabled ? page.devices : []
        delegate: Rectangle {
            id: row
            required property var modelData
            width: page.width
            height: 44
            radius: 12
            color: modelData.connected ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.22) : bm.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08) : "transparent"
            Icon {
                id: devIcon
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                name: (row.modelData.icon || "").indexOf("audio") !== -1 ? "music" : (row.modelData.icon || "").indexOf("phone") !== -1 ? "emoji" : (row.modelData.icon || "").indexOf("input") !== -1 ? "mouse" : "bluetooth"
                size: 16
            }
            Column {
                anchors.left: devIcon.right
                anchors.leftMargin: 12
                anchors.right: tools.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                PillText {
                    width: parent.width
                    text: row.modelData.name || row.modelData.deviceName || row.modelData.address
                    font.weight: row.modelData.connected ? Font.DemiBold : Font.Normal
                }
                PillText {
                    width: parent.width
                    color: Config.subtle
                    sizeFactor: 0.8
                    text: row.modelData.pairing ? "Pairing…" : row.modelData.connected ? "Connected" + (row.modelData.batteryAvailable ? "  ·  " + Math.round(row.modelData.battery * 100) + "%" : "") : row.modelData.paired ? "Paired - click to connect" : "Click to pair"
                }
            }
            Row {
                id: tools
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                IconButton {
                    visible: row.modelData.paired
                    icon: "trash"
                    size: 13
                    onClicked: row.modelData.forget()
                }
            }
            MouseArea {
                id: bm
                anchors.fill: parent
                anchors.rightMargin: 40
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const d = row.modelData;
                    if (d.connected)
                        d.disconnect();
                    else if (d.paired)
                        d.connect();
                    else {
                        d.trusted = true;
                        d.pair();
                    }
                }
            }
        }
    }

    PillText {
        visible: !!page.adapter && page.adapter.enabled && page.devices.length === 0
        width: parent.width
        wrapMode: Text.Wrap
        maximumLineCount: 2
        text: "No devices yet. Press Search and put your device in pairing mode."
        color: Config.subtle
        sizeFactor: 0.9
    }

    Rectangle {
        width: parent.width
        height: 36
        radius: 12
        color: sm.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1) : "transparent"
        PillText {
            anchors.centerIn: parent
            text: "Bluetooth settings…"
            color: Config.accent
        }
        MouseArea {
            id: sm
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                PillState.close();
                Desktop.run("btsettings");
            }
        }
    }
}
