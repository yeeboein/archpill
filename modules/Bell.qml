import QtQuick
import qs
import qs.components
import qs.services

// Bell with the number of notifications you haven't looked at.
// Shows a crossed-out bell during Do Not Disturb. Click: control centre.
Item {
    id: root
    property bool shown: true
    // Set by the pill when it stands vertically on a screen side.
    property bool vertical: false
    property string screenName: ""

    implicitWidth: row.implicitWidth
    implicitHeight: 20

    Grid {
        id: row
        // One row normally, one column in a vertical pill (left/right side).
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        anchors.verticalCenter: parent.verticalCenter
        columnSpacing: 3
        Icon {
            name: PillState.dnd ? "bell-off" : "bell"
            size: 15
            color: Notifs.unread > 0 && !PillState.dnd ? Config.accent : Config.subtle
        }
        PillText {
            visible: Notifs.unread > 0
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
