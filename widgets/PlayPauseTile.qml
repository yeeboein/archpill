import QtQuick
import qs.components
import qs.services

Tile {
    readonly property var p: Players.active
    icon: p && p.isPlaying ? "pause" : "play"
    title: p && p.isPlaying ? "Pause" : "Play"
    subtitle: p ? p.trackTitle : "Nothing playing"
    active: !!p && p.isPlaying
    onClicked: Players.togglePlaying()
}
