import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.components
import qs.services

// Last few clipboard items. Uses Plasma's clipboard (Klipper) over D-Bus on
// KDE, and cliphist (+ wl-clipboard) on other desktops. Click one to copy it
// again. Read only when the control centre opens.
Card {
    id: card
    property var items: []      // text shown
    property var ids: []        // cliphist ids (non-KDE)
    property bool failed: false
    readonly property bool useKlipper: Desktop.isKde

    // cliphist: "<id>\t<preview>" per line
    Process {
        running: !card.useKlipper
        command: ["sh", "-c", "cliphist list | head -n 5"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").filter(l => l.indexOf("\t") !== -1);
                card.ids = lines.map(l => l.split("\t")[0]);
                card.items = lines.map(l => l.slice(l.indexOf("\t") + 1));
            }
        }
        onExited: code => card.failed = code !== 0 && card.items.length === 0
    }

    Process {
        id: reader
        running: card.useKlipper
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
                required property int index
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
                        if (card.useKlipper)
                            Quickshell.execDetached(["dbus-send", "--session", "--type=method_call", "--dest=org.kde.klipper", "/klipper", "org.kde.klipper.klipper.setClipboardContents", "string:" + modelData]);
                        else
                            Quickshell.execDetached(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "sh", card.ids[index]]);
                        PillState.close();
                    }
                }
            }
        }
        PillText {
            visible: card.items.length === 0
            width: parent.width
            text: card.failed ? (card.useKlipper ? "Plasma clipboard (Klipper) not available" : "cliphist isn't running (see README)") : "Clipboard is empty"
            color: Config.subtle
        }
    }
}
