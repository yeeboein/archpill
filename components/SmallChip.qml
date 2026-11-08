import QtQuick
import qs

// Small rounded text button used inside the control centre.
Rectangle {
    id: root
    property string label: ""
    signal clicked

    width: t.implicitWidth + 20
    height: 26
    radius: 13
    color: m.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.18) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
    scale: m.pressed && Config.anim("press") ? 0.94 : 1
    Behavior on scale {
        NumberAnimation {
            duration: 90
        }
    }
    PillText {
        id: t
        anchors.centerIn: parent
        text: root.label
        sizeFactor: 0.85
    }
    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
