import QtQuick
import Quickshell.Services.Pipewire
import qs
import qs.components

// Choose where sound goes (speakers, headphones, HDMI, Bluetooth...).
Card {
    readonly property var sinks: Pipewire.nodes.values.filter(n => n && n.audio && n.isSink && !n.isStream)

    Column {
        width: parent.width
        spacing: 4
        PillText {
            text: "Sound Output"
            color: Config.subtle
            sizeFactor: 0.85
        }
        Repeater {
            model: sinks
            delegate: Rectangle {
                required property var modelData
                readonly property bool current: Pipewire.defaultAudioSink === modelData
                width: parent.width
                height: 32
                radius: 10
                color: current ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.25) : ma.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08) : "transparent"
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 8
                    spacing: 8
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: parent.parent.current ? "check" : "speaker"
                        size: 15
                        color: parent.parent.current ? Config.accent : Config.subtle
                    }
                    PillText {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.parent.width - 40
                        text: modelData.description || modelData.nickname || modelData.name
                    }
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }
        PillText {
            visible: sinks.length === 0
            text: "No outputs found"
            color: Config.subtle
        }
    }
}
