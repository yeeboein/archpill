import QtQuick
import qs

// Shared layout for the CPU / RAM / GPU cards: icon + title, big value,
// details line, usage bar and a little history graph.
Card {
    id: card
    property string icon: "chip"
    property string title: ""
    property string value: ""
    property string details: ""
    property real fraction: 0
    property var history: []

    readonly property color levelColor: fraction > 0.85 ? Config.critical : fraction > 0.65 ? Config.warning : Config.accent

    Column {
        width: parent.width
        spacing: 6
        Item {
            width: parent.width
            height: 24
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: card.icon
                    size: 16
                    color: card.levelColor
                }
                PillText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: card.title
                    font.weight: Font.DemiBold
                }
            }
            PillText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: card.value
                font.weight: Font.Bold
                sizeFactor: 1.2
            }
        }
        Sparkline {
            width: parent.width
            height: 26
            values: card.history
            color: card.levelColor
        }
        PillText {
            visible: text !== ""
            width: parent.width
            text: card.details
            color: Config.subtle
            sizeFactor: 0.85
        }
    }
}
