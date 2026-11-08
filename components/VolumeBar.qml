import QtQuick
import qs
import qs.services

// Speaker icon + volume bar + percentage. Used by the volume popup in the
// pill and by the strip that appears under the open music player.
Item {
    id: root
    implicitHeight: 22

    Icon {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        size: 18
        name: Audio.muted ? "volume-off" : Audio.volume < 0.01 ? "volume-mute" : Audio.volume < 0.5 ? "volume-down" : "volume-up"
        color: Audio.muted ? Config.subtle : Config.foreground
    }
    Rectangle {
        anchors.left: icon.right
        anchors.leftMargin: 10
        anchors.right: label.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 6
        radius: 3
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.18)
        Rectangle {
            height: parent.height
            radius: 3
            width: parent.width * Math.min(1, Audio.volume / (Math.max(1, Config.maxVolume) / 100))
            color: Audio.muted ? Config.subtle : Audio.volume > 1.0 ? Config.warning : Config.foreground
            Behavior on width {
                NumberAnimation {
                    duration: 80
                }
            }
        }
    }
    PillText {
        id: label
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        horizontalAlignment: Text.AlignRight
        text: Audio.muted ? "Muted" : Audio.percent + "%"
        color: Audio.muted ? Config.subtle : Config.foreground
        sizeFactor: 0.95
    }
}
