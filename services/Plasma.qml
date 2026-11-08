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
    // Plasma's own volume popup (plasma-pa "VolumeOsd" + "MuteOsd" settings in plasmaparc).
    property bool plasmaVolumePopup: true

    // Turn Plasma's volume popup off/on. ArchPill leaves a marker file so
    // uninstall.sh knows to turn it back on.
    function setPlasmaVolumePopup(on) {
        plasmaVolumePopup = on;
        const marker = Config.configDir + "/.plasma-volume-osd-off";
        const v = on ? "true" : "false";
        const write = k => "kwriteconfig6 --notify --file plasmaparc --group General --key " + k + " " + v;
        Quickshell.execDetached(["sh", "-c", write("VolumeOsd") + " && " + write("MuteOsd") + (on ? " && rm -f \"$1\"" : " && mkdir -p \"$(dirname \"$1\")\" && touch \"$1\""), "sh", marker]);
    }

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
        command: ["sh", "-c", "kreadconfig6 --file kwinrc --group NightColor --key Active --default false; kreadconfig6 --file kdeglobals --group General --key ColorScheme --default BreezeLight; kreadconfig6 --file plasmaparc --group General --key VolumeOsd --default true"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.trim().split("\n");
                root.nightLight = (l[0] || "").trim() === "true";
                root.colorScheme = (l[1] || "").trim();
                root.darkMode = root.colorScheme.toLowerCase().indexOf("dark") !== -1;
                root.plasmaVolumePopup = (l[2] || "true").trim() !== "false";
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
