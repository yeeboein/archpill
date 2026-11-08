import QtQuick
import qs
import qs.components
import qs.services

// Wi-Fi menu inside the control centre: on/off, networks, connect/disconnect.
Column {
    id: page
    spacing: 8

    Component.onCompleted: {
        Network.watchers++;
        Network.refresh();
        Network.scan(false);
    }
    Component.onDestruction: Network.watchers--

    // On/off row
    Rectangle {
        width: parent.width
        height: 50
        radius: 14
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
        PillText {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            text: Network.wifiEnabled ? (Network.ssid !== "" ? "Connected to " + Network.ssid : "Wi-Fi is on") : "Wi-Fi is off"
            font.weight: Font.DemiBold
            width: parent.width - 90
        }
        Switch {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: Network.wifiEnabled
            onToggled: v => {
                Network.setWifi(v);
                if (v)
                    Network.scan(true);
            }
        }
    }

    Item {
        width: parent.width
        height: 26
        visible: Network.wifiEnabled
        PillText {
            anchors.verticalCenter: parent.verticalCenter
            text: Network.scanning ? "Searching…" : "Networks"
            color: Config.subtle
            sizeFactor: 0.85
        }
        IconButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            icon: "restart"
            size: 14
            enabledAction: !Network.scanning
            onClicked: Network.scan(true)
        }
    }

    PillText {
        visible: Network.message !== ""
        width: parent.width
        text: Network.message
        color: Config.critical
        sizeFactor: 0.85
        wrapMode: Text.Wrap
        maximumLineCount: 2
    }

    Repeater {
        model: Network.wifiEnabled ? Network.networks.slice(0, 12) : []
        delegate: Rectangle {
            id: row
            required property var modelData
            width: page.width
            height: 44
            radius: 12
            color: modelData.active ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.22) : rm.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08) : "transparent"

            // signal strength as 1-4 little bars
            Row {
                id: bars
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Repeater {
                    model: 4
                    delegate: Rectangle {
                        required property int index
                        anchors.bottom: parent.bottom
                        width: 3
                        height: 4 + index * 3
                        radius: 1
                        color: row.modelData.signal >= (index + 1) * 22 ? Config.foreground : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.25)
                    }
                }
            }
            Column {
                anchors.left: bars.right
                anchors.leftMargin: 12
                anchors.right: actions.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                PillText {
                    width: parent.width
                    text: row.modelData.ssid
                    font.weight: row.modelData.active ? Font.DemiBold : Font.Normal
                }
                PillText {
                    width: parent.width
                    text: Network.busySsid === row.modelData.ssid ? "Connecting…" : row.modelData.active ? "Connected" : row.modelData.known ? "Saved" : row.modelData.secure ? "Needs password" : "Open network"
                    color: Config.subtle
                    sizeFactor: 0.8
                }
            }
            Row {
                id: actions
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                Icon {
                    visible: row.modelData.secure
                    anchors.verticalCenter: parent.verticalCenter
                    name: "lock"
                    size: 13
                    color: Config.subtle
                }
                IconButton {
                    visible: row.modelData.known && !row.modelData.active
                    icon: "trash"
                    size: 13
                    onClicked: Network.forget(row.modelData)
                }
            }
            MouseArea {
                id: rm
                anchors.fill: parent
                anchors.rightMargin: 40
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: row.modelData.active ? Network.disconnectFrom(row.modelData) : Network.connectTo(row.modelData)
            }
        }
    }

    PillText {
        visible: Network.wifiEnabled && !Network.scanning && Network.networks.length === 0
        text: "No networks found"
        color: Config.subtle
    }

    Rectangle {
        width: parent.width
        height: 36
        radius: 12
        color: sm.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1) : "transparent"
        PillText {
            anchors.centerIn: parent
            text: "Network settings…"
            color: Config.accent
        }
        MouseArea {
            id: sm
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                PillState.close();
                Network.openSettings();
            }
        }
    }
}
