import QtQuick
import qs
import qs.components

// Slider with a number next to it. Drag, click, or scroll.
Item {
    id: root
    property real from: 0
    property real to: 100
    property real step: 1
    property real value: 0
    property string suffix: ""
    property int decimals: 0
    signal moved(real value)

    width: parent ? parent.width : 260
    height: 28

    function snap(v) {
        v = Math.max(from, Math.min(to, v));
        v = Math.round((v - from) / step) * step + from;
        return Number(v.toFixed(Math.max(decimals, 4)));
    }
    readonly property real frac: to > from ? (Math.max(from, Math.min(to, value)) - from) / (to - from) : 0

    Item {
        id: track
        anchors.left: parent.left
        anchors.right: label.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 20

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            radius: 3
            color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.15)
            Rectangle {
                width: parent.width * root.frac
                height: parent.height
                radius: 3
                color: Config.accent
            }
        }
        Rectangle {
            x: root.frac * (parent.width - width)
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: 9
            color: "#ffffff"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.2)
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            preventStealing: true
            function at(x) {
                return root.snap(root.from + (x / width) * (root.to - root.from));
            }
            onPressed: mouse => root.moved(at(mouse.x))
            onPositionChanged: mouse => {
                if (pressed)
                    root.moved(at(mouse.x));
            }
            // Let the mouse wheel scroll the page instead of changing the value.
            onWheel: wheel => wheel.accepted = false
        }
    }
    PillText {
        id: label
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 64
        horizontalAlignment: Text.AlignRight
        text: Number(root.value).toFixed(root.decimals) + root.suffix
        color: Config.subtle
    }
}
