import QtQuick
import qs
import qs.components

Rectangle {
    id: root
    property string label: ""
    property bool highlight: false
    property bool danger: false
    signal clicked

    width: t.implicitWidth + 24
    height: 30
    radius: 15
    opacity: enabled ? 1 : 0.6
    color: highlight ? Config.accent : danger ? Qt.rgba(Config.critical.r, Config.critical.g, Config.critical.b, m.containsMouse ? 0.35 : 0.2) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, m.containsMouse && enabled ? 0.16 : 0.08)

    PillText {
        id: t
        anchors.centerIn: parent
        text: root.label
        sizeFactor: 0.9
        color: root.highlight ? "#ffffff" : root.danger ? Config.critical : Config.foreground
    }
    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.clicked()
    }
}
