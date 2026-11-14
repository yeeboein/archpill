import QtQuick
import qs
import qs.components
import qs.services

// Screen brightness in the pill. Scroll to change.
Item {
    id: root
    property bool shown: Brightness.available
    property bool vertical: false

    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(row.implicitHeight, 20)

    Grid {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        rowSpacing: 2
        columnSpacing: 5
        Icon {
            size: 15
            name: "sun"
        }
        PillText {
            text: Brightness.percent + (root.vertical ? "" : "%")
            sizeFactor: root.vertical ? 0.8 : 1
        }
    }
    MouseArea {
        anchors.fill: parent
        property real acc: 0
        onWheel: wheel => {
            acc += wheel.angleDelta.y;
            while (Math.abs(acc) >= 120) {
                Brightness.changeBy(acc > 0 ? 1 : -1);
                acc += acc > 0 ? -120 : 120;
            }
        }
    }
}
