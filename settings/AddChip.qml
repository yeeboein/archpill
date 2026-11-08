import QtQuick
import qs
import qs.components

// "+ Name" button used in the add menus.
Rectangle {
    id: root
    property string label: ""
    property string icon: "add"
    property string imageSource: ""
    property string tip: ""
    signal add

    width: row.implicitWidth + 22
    height: 32
    radius: 16
    color: m.containsMouse ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.25) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: "add"
            size: 14
            color: Config.accent
        }
        Image {
            visible: root.imageSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            sourceSize: Qt.size(36, 36)
            source: root.imageSource
            asynchronous: true
        }
        Icon {
            visible: root.imageSource === "" && root.icon !== "add"
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: 14
        }
        PillText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            sizeFactor: 0.9
        }
    }
    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.add()
    }
}
