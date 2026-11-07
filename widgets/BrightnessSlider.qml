import QtQuick
import qs
import qs.components
import qs.services

Column {
    spacing: 6
    Component.onCompleted: Brightness.refresh()

    PillText {
        text: Brightness.available ? "Brightness  ·  " + Math.round(Brightness.value * 100) + "%" : "Brightness  ·  not available (is brightnessctl installed?)"
        color: Config.subtle
        sizeFactor: 0.85
        width: parent.width
    }
    Slider {
        visible: Brightness.available
        width: parent.width
        value: Brightness.value
        icon: "sun"
        onMoved: v => Brightness.set(v)
    }
}
