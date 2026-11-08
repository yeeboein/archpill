import QtQuick
import qs
import qs.components

// Pick one option from a row of buttons.
// options: [{ label: "Tiny", value: "tiny" }, ...]
Flow {
    id: root
    property var options: []
    property var current
    signal picked(var value)

    width: parent ? parent.width : 260
    spacing: 4
    layoutDirection: Qt.RightToLeft

    Repeater {
        // Reversed because the row is laid out right-to-left (to sit on the
        // right), so the options still read left-to-right in their order.
        model: root.options.slice().reverse()
        delegate: Rectangle {
            required property var modelData
            readonly property bool selected: root.current === modelData.value
            width: t.implicitWidth + 20
            height: 28
            radius: 14
            color: selected ? Config.accent : m.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.14) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
            PillText {
                id: t
                anchors.centerIn: parent
                text: modelData.label
                sizeFactor: 0.9
                color: parent.selected ? "#ffffff" : Config.foreground
            }
            MouseArea {
                id: m
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.picked(modelData.value)
            }
        }
    }
}
