import QtQuick
import qs

// Apple-style slider: a rounded bar that fills up, with an icon on the left.
// Drag or scroll to change. Clicking the icon emits iconClicked (e.g. mute).
Item {
    id: root

    property real value: 0 // 0..1
    property string icon: ""
    property bool dimmed: false
    signal moved(real v)
    signal iconClicked

    implicitHeight: 34

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.12)
    }
    Rectangle {
        id: fill
        height: parent.height
        width: Math.max(height, root.value * parent.width)
        radius: height / 2
        color: root.dimmed ? Config.subtle : Config.foreground
    }
    Icon {
        id: ic
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        size: 16
        name: root.icon
        color: fill.width > 34 ? Config.background : Config.foreground
    }

    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: 32
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: mouse => root.moved(root.clamp((mouse.x + 32) / root.width))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(root.clamp((mouse.x + 32) / root.width));
        }
        property real acc: 0
        onWheel: wheel => {
            acc += wheel.angleDelta.y;
            while (Math.abs(acc) >= 120) {
                root.moved(root.clamp(root.value + (acc > 0 ? 0.05 : -0.05)));
                acc += acc > 0 ? -120 : 120;
            }
        }
    }
    MouseArea {
        width: 32
        height: parent.height
        cursorShape: Qt.PointingHandCursor
        onClicked: root.iconClicked()
    }
}
