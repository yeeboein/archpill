pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Screen brightness via `brightnessctl` (install.sh installs it).
//
// Changes are noticed without polling: on KDE, PowerDevil announces every
// brightness change on D-Bus (brightness keys, battery applet, anything) and
// we listen with `dbus-monitor`. On other desktops, run
// `qs -c archpill ipc call archpill showBrightness` from your brightness key
// bindings. Each change refreshes the value and shows the popup in the pill.
Singleton {
    id: root

    property bool available: false
    property real value: 0.5 // 0..1
    readonly property int percent: Math.round(value * 100)

    // true = the next reading should show the popup (a change came from outside)
    property bool announceNext: false
    // ignore change signals for a moment after we set brightness ourselves (slider)
    property real ownChangeUntil: 0

    function refresh() {
        if (!reader.running)
            reader.running = true;
    }

    // Brightness changed somewhere else: read it and show it in the pill.
    function changedExternally() {
        if (Date.now() < ownChangeUntil)
            return;
        announceNext = true;
        refreshSoon.restart();
    }

    function set(v) {
        value = Math.max(0.01, Math.min(1, v));
        ownChangeUntil = Date.now() + 800;
        writeTimer.restart();
    }

    function changeBy(steps) {
        set(value + steps * 0.05);
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
                    if (root.announceNext && Config.osdBrightness)
                        PillState.showOsd("brightness");
                }
                root.announceNext = false;
            }
        }
        onExited: code => {
            if (code !== 0)
                root.available = false;
        }
    }

    Timer {
        id: refreshSoon
        interval: 40 // groups the burst of signals a key press can cause
        onTriggered: root.refresh()
    }

    // KDE: listen for PowerDevil's brightness signals (event-driven, no polling).
    Process {
        running: Desktop.isKde
        command: ["dbus-monitor", "--session", "type='signal',interface='org.kde.ScreenBrightness',member='BrightnessChanged'", "type='signal',interface='org.kde.Solid.PowerManagement.Actions.BrightnessControl',member='brightnessChanged'"]
        stdout: SplitParser {
            onRead: line => {
                if (line.indexOf("member=BrightnessChanged") !== -1 || line.indexOf("member=brightnessChanged") !== -1)
                    root.changedExternally();
            }
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
