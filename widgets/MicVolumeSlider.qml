import QtQuick
import qs
import qs.components
import qs.services

Column {
    spacing: 6
    PillText {
        width: parent.width
        text: Audio.micReady ? "Microphone  ·  " + (Audio.micMuted ? "Muted" : Math.round(Audio.source.audio.volume * 100) + "%") : "Microphone  ·  none found"
        color: Config.subtle
        sizeFactor: 0.85
    }
    Slider {
        visible: Audio.micReady
        width: parent.width
        value: Audio.micReady ? Audio.source.audio.volume : 0
        dimmed: Audio.micMuted
        icon: Audio.micMuted ? "mic-off" : "mic"
        onMoved: v => {
            Audio.source.audio.volume = v;
            if (Audio.micMuted && v > 0)
                Audio.source.audio.muted = false;
        }
        onIconClicked: Audio.toggleMic()
    }
}
