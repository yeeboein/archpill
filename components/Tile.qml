import QtQuick
import qs

// A control-centre toggle tile: round icon, title and a small status line.
// Left click toggles, right click usually opens the matching System Settings page.
Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked
    signal rightClicked

    implicitHeight: 58
    radius: 18
    color: mouse.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.13) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)

    Rectangle {
        id: circle
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        radius: 18
        color: root.active ? Config.accent : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.14)
        Icon {
            anchors.centerIn: parent
            size: 18
            name: root.icon
            color: root.active ? "#ffffff" : Config.foreground
        }
    }

    Column {
        anchors.left: circle.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        PillText {
            width: parent.width
            text: root.title
            font.weight: Font.DemiBold
        }
        PillText {
            width: parent.width
            visible: text !== ""
            text: root.subtitle
            color: Config.subtle
            sizeFactor: 0.85
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: m => m.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    }
}
