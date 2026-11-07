import QtQuick
import qs

// A round, clickable icon. Lights up slightly on hover.
Item {
    id: root

    property alias icon: ic.name
    property int size: 16
    property bool enabledAction: true
    signal clicked

    implicitWidth: size + 10
    implicitHeight: size + 10
    opacity: enabledAction ? 1 : 0.35

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Config.foreground
        opacity: mouse.containsMouse && root.enabledAction ? (mouse.pressed ? 0.22 : 0.12) : 0
    }

    Icon {
        id: ic
        anchors.centerIn: parent
        size: root.size
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.enabledAction) root.clicked()
    }
}
