pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen brightness via `brightnessctl` (install.sh installs it).
// Read once at start and whenever the control centre opens - no polling.
Singleton {
    id: root

    property bool available: false
    property real value: 0.5 // 0..1

    function refresh() {
        if (!reader.running)
            reader.running = true;
    }

    function set(v) {
        value = Math.max(0.01, Math.min(1, v));
        writeTimer.restart();
    }

    Process {
        id: reader
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                // e.g. "intel_backlight,backlight,120,47%,255"
                const f = text.trim().split("\n")[0].split(",");
                if (f.length >= 5 && Number(f[4]) > 0) {
                    root.value = Number(f[2]) / Number(f[4]);
                    root.available = true;
                }
            }
        }
        onExited: code => {
            if (code !== 0)
                root.available = false;
        }
    }

    // Don't spawn a process for every pixel of slider movement.
    Timer {
        id: writeTimer
        interval: 60
        onTriggered: Quickshell.execDetached(["brightnessctl", "-q", "-c", "backlight", "set", Math.round(root.value * 100) + "%"])
    }

    Component.onCompleted: refresh()
}
