import QtQuick
import qs
import qs.components
import qs.services

// Notification history: newest first, click one to remove it, "Clear all".
Card {
    id: card
    Component.onCompleted: Notifs.markRead()

    function ago(t) {
        const s = Math.floor((Date.now() - t) / 1000);
        if (s < 60)
            return "now";
        if (s < 3600)
            return Math.floor(s / 60) + " min";
        if (s < 86400)
            return Math.floor(s / 3600) + " h";
        return Math.floor(s / 86400) + " d";
    }

    Column {
        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: 26
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: PillState.dnd ? "bell-off" : "bell"
                    size: 15
                    color: PillState.dnd ? Config.subtle : Config.foreground
                }
                PillText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notifications" + (PillState.dnd ? "  ·  Do Not Disturb" : "")
                    font.weight: Font.DemiBold
                }
            }
            SmallChip {
                visible: Notifs.history.length > 0
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                label: "Clear all"
                onClicked: Notifs.clearHistory()
            }
        }

        Repeater {
            model: Notifs.history.slice(0, 6)
            delegate: Rectangle {
                id: row
                required property var modelData
                width: parent.width
                height: Math.max(46, texts.implicitHeight + 12)
                radius: 12
                color: hm.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.04)
                Image {
                    id: ico
                    x: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 26
                    height: 26
                    sourceSize: Qt.size(52, 52)
                    source: row.modelData.icon
                    asynchronous: true
                    visible: status === Image.Ready
                }
                Icon {
                    visible: ico.status !== Image.Ready
                    x: 13
                    anchors.verticalCenter: parent.verticalCenter
                    name: "bell"
                    size: 16
                    color: row.modelData.critical ? Config.critical : Config.subtle
                }
                Column {
                    id: texts
                    anchors.left: parent.left
                    anchors.leftMargin: 44
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    PillText {
                        width: parent.width
                        text: row.modelData.app + "  ·  " + card.ago(row.modelData.time)
                        color: Config.subtle
                        sizeFactor: 0.75
                    }
                    PillText {
                        width: parent.width
                        text: row.modelData.summary
                        textFormat: Text.PlainText
                        font.weight: Font.DemiBold
                        sizeFactor: 0.9
                    }
                    PillText {
                        width: parent.width
                        visible: text !== ""
                        text: row.modelData.body.replace(/<[^>]*>/g, "")
                        textFormat: Text.PlainText
                        color: Config.subtle
                        sizeFactor: 0.85
                    }
                }
                MouseArea {
                    id: hm
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.removeFromHistory(row.modelData.id)
                }
            }
        }

        PillText {
            visible: Notifs.history.length === 0
            width: parent.width
            text: Notifs.active ? "No notifications" : "Notifications are handled by " + Notifs.ownerName + ". Settings → Behaviour → Notifications to switch."
            wrapMode: Text.Wrap
            maximumLineCount: 3
            color: Config.subtle
            sizeFactor: 0.9
        }
        PillText {
            visible: Notifs.history.length > 6
            text: "+ " + (Notifs.history.length - 6) + " more"
            color: Config.subtle
            sizeFactor: 0.8
        }
    }
}
