import QtQuick
import qs.components
import qs.services

Tile {
    icon: Audio.micMuted ? "mic-off" : "mic"
    title: "Microphone"
    subtitle: !Audio.micReady ? "No microphone" : Audio.micMuted ? "Muted" : "On"
    active: Audio.micReady && !Audio.micMuted
    onClicked: Audio.toggleMic()
}
