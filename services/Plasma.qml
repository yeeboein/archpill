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
        const v = on ? "true" : "false";
        const marker = Config.configDir + "/.plasma-volume-osd-off";
        run([
            ["kwriteconfig6", "--notify", "--file", "plasmaparc", "--group", "General", "--key", "VolumeOsd", v],
            ["kwriteconfig6", "--notify", "--file", "plasmaparc", "--group", "General", "--key", "MuteOsd", v],
            on ? ["rm", "-f", marker] : ["touch", marker]
        ]);
    }

    // Runs commands one after another, logs failures, then re-reads the
    // real settings so buttons always show what actually happened.
    property var queue: []
    function run(cmds) {
        queue = queue.concat(cmds);
        if (!runner.running)
            next();
    }
    function next() {
        if (queue.length === 0) {
            refresh();
            return;
        }
        runner.command = queue[0];
        queue = queue.slice(1);
        runner.running = true;
    }
    Process {
        id: runner
        stderr: StdioCollector {
            id: runnerErr
        }
        onExited: code => {
            if (code !== 0)
                console.warn("[archpill] command failed (" + code + "): " + runner.command.join(" ") + " " + runnerErr.text);
            else
                console.info("[archpill] ran: " + runner.command.join(" "));
            root.next();
        }
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
