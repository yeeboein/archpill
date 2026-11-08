import QtQuick
import qs

Item {
    property bool shown: true
    implicitWidth: 4
    implicitHeight: 4
    Rectangle {
        anchors.centerIn: parent
        width: 4
        height: 4
        radius: 2
        color: Config.subtle
        opacity: 0.6
    }
}
