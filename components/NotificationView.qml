import QtQuick
import qs
import qs.services

// The notification shown when the pill expands: app icon, app name, title,
// text and action buttons. Click it to open/dismiss, × to dismiss.
Item {
    id: root
    readonly property var n: Notifs.current
    readonly property bool critical: !!n && n.urgency === 2

    implicitHeight: Math.max(48, col.implicitHeight)

    // Click anywhere: run the app's default action (if any) and dismiss.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifs.invokeDefault()
    }

    Rectangle {
        id: iconBox
        width: 44
        height: 44
        radius: 12
        color: root.critical ? Qt.rgba(Config.critical.r, Config.critical.g, Config.critical.b, 0.25) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
        clip: true
        Image {
            id: img
            anchors.fill: parent
            anchors.margins: root.n && root.n.image ? 0 : 6
            source: root.n ? Notifs.iconFor(root.n) : ""
            sourceSize: Qt.size(88, 88)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
        }
        Icon {
            anchors.centerIn: parent
            visible: img.status !== Image.Ready
            name: "bell"
            size: 20
            color: root.critical ? Config.critical : Config.subtle
        }
    }

    Column {
        id: col
        anchors.left: iconBox.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        spacing: 2

        Item {
            width: parent.width
            height: appLabel.implicitHeight
            PillText {
                id: appLabel
                width: parent.width - 30
                text: root.n ? (root.n.appName || "Notification") + "  ·  now" : ""
                color: root.critical ? Config.critical : Config.subtle
                sizeFactor: 0.8
            }
            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: -6
                icon: "close"
                size: 12
                onClicked: Notifs.dismissCurrent()
            }
        }
        PillText {
            width: parent.width
            text: root.n ? root.n.summary : ""
            textFormat: Text.PlainText
            font.weight: Font.DemiBold
            wrapMode: Text.Wrap
            maximumLineCount: 2
        }
        PillText {
            width: parent.width
            visible: text !== ""
            text: root.n ? root.n.body.replace(/<[^>]*>/g, "") : ""
            textFormat: Text.PlainText
            color: Config.subtle
            sizeFactor: 0.92
            wrapMode: Text.Wrap
            maximumLineCount: 3
        }
        // Action buttons (except the hidden "default" one).
        Flow {
            width: parent.width
            spacing: 6
            topPadding: visible ? 6 : 0
            visible: actions.count > 0
            Repeater {
                id: actions
                model: root.n ? root.n.actions.filter(a => a.identifier !== "default" && a.text !== "") : []
                delegate: SmallChip {
                    required property var modelData
                    label: modelData.text
                    onClicked: {
                        modelData.invoke();
                        Notifs.dismissCurrent();
                    }
                }
            }
        }
    }
}
