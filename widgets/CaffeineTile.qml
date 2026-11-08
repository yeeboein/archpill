import QtQuick
import qs.components
import qs.services

Tile {
    icon: "coffee"
    title: "Stay Awake"
    subtitle: Plasma.caffeine ? "Screen stays on" : "Off"
    active: Plasma.caffeine
    onClicked: Plasma.caffeine = !Plasma.caffeine
}
