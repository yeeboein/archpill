import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Lock / Sleep / Log out. On KDE "Log out" opens Plasma's own logout
// screen (which also has Restart and Shut Down).
Card {
    Row {
        width: parent.width
        spacing: 8

        Repeater {
            model: [
                { icon: "lock", label: "Lock", run: "lock" },
                { icon: "moon", label: "Sleep", run: "sleep" },
                { icon: "power", label: Desktop.isKde ? "Log out…" : "Log out", run: "logout" }
            ]
            delegate: Rectangle {
                required property var modelData
                width: (parent.width - 16) / 3
                height: 54
                radius: 14
                color: ma.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.14) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.06)
                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: modelData.icon
                        size: 18
                    }
                    PillText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label
                        sizeFactor: 0.85
                    }
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        PillState.close();
                        Desktop.run(modelData.run);
                    }
                }
            }
        }
    }
}
