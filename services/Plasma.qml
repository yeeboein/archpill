pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Small bridges to Plasma features: Night Light, Dark Mode, Stay Awake.
// State is read when the control centre opens (refresh), never polled.
Singleton {
    id: root

    property bool nightLight: false
    property bool darkMode: false
    property string colorScheme: ""
    property bool caffeine: false

    function refresh() {
        if (!reader.running)
            reader.running = true;
    }

    function setNightLight(on) {
        nightLight = on;
        Quickshell.execDetached(["sh", "-c", "kwriteconfig6 --file kwinrc --group NightColor --key Active " + (on ? "true" : "false") + " && dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure"]);
    }

    function openNightLightSettings() {
        Quickshell.execDetached(["systemsettings", "kcm_nightlight"]);
    }

    function setDarkMode(on) {
        darkMode = on;
        Quickshell.execDetached(["plasma-apply-colorscheme", on ? Config.darkScheme : Config.lightScheme]);
    }

    Process {
        id: reader
        command: ["sh", "-c", "kreadconfig6 --file kwinrc --group NightColor --key Active --default false; kreadconfig6 --file kdeglobals --group General --key ColorScheme --default BreezeLight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.trim().split("\n");
                root.nightLight = (l[0] || "").trim() === "true";
                root.colorScheme = (l[1] || "").trim();
                root.darkMode = root.colorScheme.toLowerCase().indexOf("dark") !== -1;
            }
        }
    }

    // "Stay awake": hold a systemd inhibitor while it's on.
    Process {
        running: root.caffeine
        command: ["systemd-inhibit", "--what=idle:sleep", "--who=ArchPill", "--why=Stay awake is on", "--mode=block", "sleep", "infinity"]
    }

    Component.onCompleted: refresh()
}
