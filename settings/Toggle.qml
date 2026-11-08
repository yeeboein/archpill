import QtQuick
import qs

// On/off switch.
Item {
    id: root
    property bool checked: false
    signal toggled(bool value)

    anchors.right: parent ? parent.right : undefined
    width: 44
    height: 24

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Config.accent : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.2)
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
        Rectangle {
            width: 20
            height: 20
            radius: 10
            y: 2
            x: root.checked ? parent.width - width - 2 : 2
            color: "#ffffff"
            Behavior on x {
                NumberAnimation {
                    duration: 120
                }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
