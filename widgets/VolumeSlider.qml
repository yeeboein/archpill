import QtQuick
import qs
import qs.components
import qs.services

Column {
    readonly property real maxV: Math.max(1, Config.maxVolume) / 100
    spacing: 6

    PillText {
        text: "Volume  ·  " + (Audio.muted ? "Muted" : Audio.percent + "%")
        color: Config.subtle
        sizeFactor: 0.85
    }
    Slider {
        width: parent.width
        value: Audio.volume / parent.maxV
        dimmed: Audio.muted
        icon: Audio.muted ? "volume-off" : Audio.volume < 0.01 ? "volume-mute" : Audio.volume < 0.5 ? "volume-down" : "volume-up"
        onMoved: v => Audio.setVolume(v * parent.maxV)
        onIconClicked: Audio.toggleMute()
    }
}
