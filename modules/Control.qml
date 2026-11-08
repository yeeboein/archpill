import QtQuick
import qs
import qs.components
import qs.services

// Button that expands the pill into the control centre.
Item {
    id: root

    property bool shown: true
    property string screenName: ""

    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    IconButton {
        id: btn
        icon: "tune"
        size: 16
        onClicked: PillState.toggle("control", root.screenName)
    }
    // Little dot when an update is waiting.
    Rectangle {
        visible: Updater.available
        anchors.right: btn.right
        anchors.top: btn.top
        anchors.margins: 3
        width: 7
        height: 7
        radius: 4
        color: Config.accent
    }
}
