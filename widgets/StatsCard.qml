import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.components

// CPU, memory and disk. Reads /proc every 2 s, only while visible.
Card {
    id: card
    property real cpu: 0
    property real mem: 0
    property string memText: ""
    property string diskText: ""
    property real disk: 0
    property var lastCpu: null

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + (f[4] || 0);
            const total = f.reduce((a, b) => a + b, 0);
            if (card.lastCpu) {
                const dt = total - card.lastCpu.total, di = idle - card.lastCpu.idle;
                card.cpu = dt > 0 ? Math.max(0, Math.min(1, 1 - di / dt)) : 0;
            }
            card.lastCpu = { total: total, idle: idle };
        }
    }
    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const t = text();
            const get = k => {
                const m = t.match(new RegExp(k + ":\\s+(\\d+)"));
                return m ? Number(m[1]) : 0;
            };
            const total = get("MemTotal"), avail = get("MemAvailable");
            card.mem = total > 0 ? (total - avail) / total : 0;
            card.memText = ((total - avail) / 1048576).toFixed(1) + " / " + (total / 1048576).toFixed(1) + " GB";
        }
    }
    Process {
        id: df
        command: ["df", "-B1", "--output=used,size", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.trim().split("\n");
                const f = (l[1] || "").trim().split(/\s+/).map(Number);
                if (f.length === 2 && f[1] > 0) {
                    card.disk = f[0] / f[1];
                    card.diskText = (f[0] / 1e9).toFixed(0) + " / " + (f[1] / 1e9).toFixed(0) + " GB";
                }
            }
        }
    }
    Timer {
        interval: 2000
        repeat: true
        triggeredOnStart: true
        running: card.visible
        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
    }
    Component.onCompleted: df.running = true

    component Bar: Column {
        property string label
        property string value
        property real frac
        width: parent.width
        spacing: 3
        Item {
            width: parent.width
            height: lbl.implicitHeight
            PillText {
                id: lbl
                text: parent.parent.label
                sizeFactor: 0.85
            }
            PillText {
                anchors.right: parent.right
                text: parent.parent.value
                color: Config.subtle
                sizeFactor: 0.85
            }
        }
        Rectangle {
            width: parent.width
            height: 6
            radius: 3
            color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.12)
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, parent.parent.frac))
                height: parent.height
                radius: 3
                color: parent.parent.frac > 0.85 ? Config.critical : parent.parent.frac > 0.65 ? Config.warning : Config.accent
            }
        }
    }

    Column {
        width: parent.width
        spacing: 8
        Bar {
            label: "CPU"
            value: Math.round(card.cpu * 100) + "%"
            frac: card.cpu
        }
        Bar {
            label: "Memory"
            value: card.memText
            frac: card.mem
        }
        Bar {
            label: "Disk"
            value: card.diskText
            frac: card.disk
        }
    }
}
