import QtQuick
import qs.components
import qs.services

Tile {
    icon: "next"
    title: "Next Track"
    subtitle: Players.active ? Players.displayName(Players.active) : "Nothing playing"
    onClicked: Players.next()
}
