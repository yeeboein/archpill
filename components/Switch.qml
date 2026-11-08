import QtQuick
import qs

// On/off switch for the pill and control centre.
Item {
    id: root
    property bool checked: false
    signal toggled(bool value)

    width: 44
    height: 24

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Config.accent : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.2)
        Behavior on color {
            enabled: Config.anim("tileGlow")
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
                enabled: Config.anim("press")
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
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
