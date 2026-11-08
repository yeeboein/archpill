import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Stopwatch and countdown. Keeps running when the control centre closes.
// A countdown sends a desktop notification when it ends.
Card {
    id: card

    component Chip: Rectangle {
        property string label
        property bool highlight: false
        signal tapped
        width: t.implicitWidth + 18
        height: 28
        radius: 14
        color: highlight ? Config.accent : m.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.16) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
        PillText {
            id: t
            anchors.centerIn: parent
            text: parent.label
            sizeFactor: 0.85
            color: parent.highlight ? "#ffffff" : Config.foreground
        }
        MouseArea {
            id: m
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.tapped()
        }
    }

    Column {
        width: parent.width
        spacing: 8

        Item {
            width: parent.width
            height: big.implicitHeight
            PillText {
                id: big
                text: TimerState.display
                sizeFactor: 2
                font.weight: Font.Bold
                font.family: "monospace"
            }
            PillText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: TimerState.mode === "countdown" ? "Countdown" : "Stopwatch"
                color: Config.subtle
                sizeFactor: 0.85
            }
        }

        Flow {
            width: parent.width
            spacing: 6

            Chip {
                label: TimerState.running ? "Pause" : (TimerState.elapsedMs > 0 || TimerState.remainingMs > 0 ? "Resume" : "Start")
                highlight: true
                onTapped: TimerState.running ? TimerState.pause() : TimerState.start()
            }
            Chip {
                label: "Reset"
                onTapped: TimerState.reset()
            }
            Chip {
                label: "1 min"
                onTapped: TimerState.countdown(60)
            }
            Chip {
                label: "5 min"
                onTapped: TimerState.countdown(300)
            }
            Chip {
                label: "10 min"
                onTapped: TimerState.countdown(600)
            }
            Chip {
                label: "25 min"
                onTapped: TimerState.countdown(1500)
            }
        }
    }
}
