import QtQuick
import qs.components
import qs.services

Tile {
    icon: "contrast"
    title: "Dark Mode"
    subtitle: Plasma.darkMode ? "On" : "Off"
    active: Plasma.darkMode
    onClicked: Plasma.setDarkMode(!Plasma.darkMode)
    Component.onCompleted: Plasma.refresh()
}
