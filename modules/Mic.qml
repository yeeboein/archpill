import QtQuick
import qs
import qs.components
import qs.services

// A red mic icon that only shows while your microphone is muted. Click to unmute.
Item {
    property bool shown: Audio.micReady && Audio.micMuted
    implicitWidth: 18
    implicitHeight: 18
    Icon {
        anchors.centerIn: parent
        size: 16
        name: "mic-off"
        color: Config.critical
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Audio.toggleMic()
    }
}
