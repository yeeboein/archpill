import QtQuick
import qs
import qs.services

// Speaker icon + volume bar + percentage. Used by the volume popup in the
// pill and by the strip that appears under the open music player.
Item {
    id: root
    // Vertical: icon on top, bar going up, percentage at the bottom.
    property bool vertical: false
    implicitHeight: 22
    readonly property real level: Math.min(1, Audio.volume / (Math.max(1, Config.maxVolume) / 100))

    Icon {
        id: icon
        visible: !root.vertical
        anchors.verticalCenter: parent.verticalCenter
        size: 18
        name: Audio.muted ? "volume-off" : Audio.volume < 0.01 ? "volume-mute" : Audio.volume < 0.5 ? "volume-down" : "volume-up"
        color: Audio.muted ? Config.subtle : Config.foreground
    }
    Rectangle {
        visible: !root.vertical
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
        visible: !root.vertical
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        horizontalAlignment: Text.AlignRight
        text: Audio.muted ? "Muted" : Audio.percent + "%"
        color: Audio.muted ? Config.subtle : Config.foreground
        sizeFactor: 0.95
    }

    // ---- vertical version ----
    Column {
        visible: root.vertical
        anchors.fill: parent
        spacing: 6
        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            size: 18
            name: icon.name
            color: icon.color
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 6
            height: parent.height - 18 - vLabel.implicitHeight - 12
            radius: 3
            color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.18)
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * root.level
                radius: 3
                color: Audio.muted ? Config.subtle : Audio.volume > 1.0 ? Config.warning : Config.foreground
                Behavior on height {
                    NumberAnimation {
                        duration: 80
                    }
                }
            }
        }
        PillText {
            id: vLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: Audio.muted ? "Off" : Audio.percent
            sizeFactor: 0.8
        }
    }
}
