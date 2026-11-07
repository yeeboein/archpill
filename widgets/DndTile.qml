import QtQuick
import qs.components
import qs.services

Tile {
    icon: "moon"
    title: "Do Not Disturb"
    subtitle: PillState.dnd ? "On" : "Off"
    active: PillState.dnd
    onClicked: PillState.dnd = !PillState.dnd
}
