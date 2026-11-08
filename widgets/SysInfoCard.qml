import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.components

Card {
    id: card
    property string host: ""
    property string kernel: ""
    property string uptime: ""

    FileView {
        path: "/proc/sys/kernel/hostname"
        onLoaded: card.host = text().trim()
    }
    FileView {
        path: "/proc/sys/kernel/osrelease"
        onLoaded: card.kernel = text().trim()
    }
    FileView {
        path: "/proc/uptime"
        onLoaded: {
            const s = Number(text().split(" ")[0]);
            const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
            card.uptime = (d > 0 ? d + " d " : "") + (h > 0 ? h + " h " : "") + m + " min";
        }
    }

    Column {
        width: parent.width
        spacing: 2
        PillText {
            text: (Quickshell.env("USER") || "") + "@" + card.host
            font.weight: Font.DemiBold
        }
        PillText {
            text: "Linux " + card.kernel
            color: Config.subtle
            sizeFactor: 0.85
        }
        PillText {
            text: "Up " + card.uptime
            color: Config.subtle
            sizeFactor: 0.85
        }
    }
}
