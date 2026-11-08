import QtQuick
import qs

// A divider between modules. Add as many as you like.
// style: "dot", "line", "space" or "wide".
Item {
    id: root
    property bool shown: true
    property string style: "dot"
    property bool vertical: false // in a vertical pill everything turns sideways

    readonly property real along: style === "wide" ? 24 : style === "space" ? 6 : style === "line" ? 1 : 4
    readonly property real across: style === "line" ? Math.round(Config.pillHeight * 0.45) : 4
    implicitWidth: vertical ? across : along
    implicitHeight: vertical ? along : across

    Rectangle {
        visible: root.style === "dot"
        anchors.centerIn: parent
        width: 4
        height: 4
        radius: 2
        color: Config.subtle
        opacity: 0.6
    }
    Rectangle {
        visible: root.style === "line"
        anchors.fill: parent
        color: Config.subtle
        opacity: 0.4
    }
}
