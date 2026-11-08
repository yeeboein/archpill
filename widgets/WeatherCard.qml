import QtQuick
import qs
import qs.components
import qs.services

Card {
    Component.onCompleted: Weather.refresh(false)

    Row {
        width: parent.width
        spacing: 12

        PillText {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.ok ? Weather.icon : ""
            sizeFactor: 2.4
            visible: Weather.ok
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 70
            PillText {
                width: parent.width
                text: Weather.ok ? Weather.temp + "  " + Weather.condition : Weather.loading ? "Loading weather…" : "Weather unavailable (offline?)"
                font.weight: Font.DemiBold
                sizeFactor: Weather.ok ? 1.15 : 1
            }
            PillText {
                width: parent.width
                visible: Weather.ok
                text: (Weather.place ? Weather.place + " · " : "") + (Weather.feels ? "feels " + Weather.feels : "") + (Weather.wind ? " · " + Weather.wind : "")
                color: Config.subtle
                sizeFactor: 0.85
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Weather.refresh(true)
    }
}
