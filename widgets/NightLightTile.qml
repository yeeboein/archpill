import QtQuick
import qs.components
import qs.services

Tile {
    icon: "bulb"
    title: "Night Light"
    subtitle: Plasma.nightLight ? "On" : "Off"
    active: Plasma.nightLight
    onClicked: Plasma.setNightLight(!Plasma.nightLight)
    onRightClicked: Plasma.openNightLightSettings()
    Component.onCompleted: Plasma.refresh()
}
