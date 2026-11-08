import QtQuick
import qs

// Tiny bar graph of recent values (0..1). Plain rectangles: cheap to draw.
Item {
    id: root
    property var values: []
    property color color: Config.accent
    readonly property int count: 40

    implicitHeight: 28

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        spacing: 1
        Repeater {
            model: root.values
            delegate: Rectangle {
                required property var modelData
                width: Math.max(1, (root.width - root.count) / root.count)
                height: Math.max(1, root.height * Math.min(1, modelData))
                anchors.bottom: parent ? parent.bottom : undefined
                radius: 1
                color: root.color
                opacity: 0.85
            }
        }
    }
}
