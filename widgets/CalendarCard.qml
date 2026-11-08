import QtQuick
import Quickshell
import qs
import qs.components

// Month calendar. Today is highlighted; arrows flip months.
Card {
    id: card
    property int offset: 0 // months from now

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    readonly property date shown: {
        const d = new Date(clock.date.getFullYear(), clock.date.getMonth() + offset, 1);
        return d;
    }
    // Monday-first grid of 42 days
    readonly property var days: {
        const first = new Date(shown.getFullYear(), shown.getMonth(), 1);
        const startDow = (first.getDay() + 6) % 7;
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(shown.getFullYear(), shown.getMonth(), 1 - startDow + i);
            out.push({ day: d.getDate(), inMonth: d.getMonth() === shown.getMonth(), today: d.toDateString() === clock.date.toDateString() });
        }
        return out;
    }

    Column {
        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: 26
            PillText {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDate(card.shown, "MMMM yyyy")
                font.weight: Font.DemiBold
            }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                IconButton {
                    icon: "chevron-left"
                    size: 14
                    onClicked: card.offset--
                }
                IconButton {
                    icon: "dot"
                    size: 10
                    enabledAction: card.offset !== 0
                    onClicked: card.offset = 0
                }
                IconButton {
                    icon: "chevron-right"
                    size: 14
                    onClicked: card.offset++
                }
            }
        }

        Grid {
            columns: 7
            width: parent.width
            readonly property real cell: width / 7

            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                delegate: PillText {
                    required property var modelData
                    width: parent.cell
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Config.subtle
                    sizeFactor: 0.8
                }
            }
            Repeater {
                model: card.days
                delegate: Item {
                    required property var modelData
                    width: parent.cell
                    height: 26
                    Rectangle {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        radius: 12
                        color: Config.accent
                        visible: modelData.today
                    }
                    PillText {
                        anchors.centerIn: parent
                        text: modelData.day
                        sizeFactor: 0.9
                        color: modelData.today ? "#ffffff" : modelData.inMonth ? Config.foreground : Qt.rgba(Config.subtle.r, Config.subtle.g, Config.subtle.b, 0.5)
                    }
                }
            }
        }
    }
}
