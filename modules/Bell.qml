import QtQuick
import qs
import qs.components
import qs.services

// Bell with the number of notifications you haven't looked at.
// Shows a crossed-out bell during Do Not Disturb. Click: control centre.
Item {
    id: root
    property bool shown: true
    property string screenName: ""

    implicitWidth: row.implicitWidth
    implicitHeight: 20

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: PillState.dnd ? "bell-off" : "bell"
            size: 15
            color: Notifs.unread > 0 && !PillState.dnd ? Config.accent : Config.subtle
        }
        PillText {
            visible: Notifs.unread > 0
            anchors.verticalCenter: parent.verticalCenter
            text: Notifs.unread > 99 ? "99+" : Notifs.unread
            sizeFactor: 0.85
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: PillState.toggle("control", root.screenName)
    }
}
