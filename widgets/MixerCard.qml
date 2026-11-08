import QtQuick
import Quickshell.Services.Pipewire
import qs
import qs.components

// One volume slider per app that is playing sound right now.
Card {
    id: card
    readonly property var streams: Pipewire.nodes.values.filter(n => n && n.audio && n.isStream && !n.isSink)

    PwObjectTracker {
        objects: card.streams
    }

    Column {
        width: parent.width
        spacing: 8
        PillText {
            text: "App Volumes"
            color: Config.subtle
            sizeFactor: 0.85
        }
        Repeater {
            model: card.streams
            delegate: Column {
                required property var modelData
                width: parent.width
                spacing: 3
                PillText {
                    width: parent.width
                    sizeFactor: 0.85
                    text: {
                        const p = modelData.properties || {};
                        const app = p["application.name"] || modelData.description || modelData.name || "App";
                        const media = p["media.name"] || "";
                        return media && media !== app ? app + " · " + media : app;
                    }
                }
                Slider {
                    width: parent.width
                    implicitHeight: 26
                    value: modelData.ready ? modelData.audio.volume : 0
                    dimmed: modelData.ready && modelData.audio.muted
                    icon: modelData.ready && modelData.audio.muted ? "volume-off" : "volume-up"
                    onMoved: v => modelData.audio.volume = v
                    onIconClicked: modelData.audio.muted = !modelData.audio.muted
                }
            }
        }
        PillText {
            visible: card.streams.length === 0
            text: "No apps are playing sound"
            color: Config.subtle
        }
    }
}
