import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.components
import qs.services

// Last few clipboard items from Plasma's clipboard (Klipper) over D-Bus.
// Click one to copy it again. Read only when the control centre opens.
Card {
    id: card
    property var items: []
    property bool failed: false

    Process {
        id: reader
        running: true
        command: ["sh", "-c", "for i in 0 1 2 3 4; do dbus-send --session --print-reply=literal --dest=org.kde.klipper /klipper org.kde.klipper.klipper.getClipboardHistoryItem int32:$i || exit 1; printf '\\n\\036\\n'; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("\n\u001e\n").map(s => s.replace(/^\s+/, "").trim()).filter(s => s !== "");
                card.items = parts;
            }
        }
        onExited: code => card.failed = code !== 0 && card.items.length === 0
    }

    Column {
        width: parent.width
        spacing: 4
        PillText {
            text: "Clipboard"
            color: Config.subtle
            sizeFactor: 0.85
        }
        Repeater {
            model: card.items
            delegate: Rectangle {
                required property var modelData
                width: parent.width
                height: 30
                radius: 10
                color: ma.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1) : "transparent"
                PillText {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 8
                    width: parent.width - 16
                    text: modelData.replace(/\s+/g, " ")
                    sizeFactor: 0.9
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["dbus-send", "--session", "--type=method_call", "--dest=org.kde.klipper", "/klipper", "org.kde.klipper.klipper.setClipboardContents", "string:" + modelData]);
                        PillState.close();
                    }
                }
            }
        }
        PillText {
            visible: card.items.length === 0
            width: parent.width
            text: card.failed ? "Plasma clipboard (Klipper) not available" : "Clipboard is empty"
            color: Config.subtle
        }
    }
}
