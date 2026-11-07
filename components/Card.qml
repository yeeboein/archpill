import QtQuick
import qs

// Rounded background for wide control-centre widgets.
Rectangle {
    default property alias content: inner.data
    property int padding: 12

    implicitHeight: inner.childrenRect.height + padding * 2
    radius: 18
    color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)

    Item {
        id: inner
        x: parent.padding
        y: parent.padding
        width: parent.width - parent.padding * 2
        height: childrenRect.height
    }
}
