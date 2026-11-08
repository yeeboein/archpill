pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Bridges to desktop features: Night Light, Dark Mode, Stay Awake and
// Plasma's volume popup. Each one picks the right method for your desktop
// (KDE, GNOME, or a sunset tool / GTK setting on Hyprland, Sway, niri...).
// State is read when the control centre opens (refresh), never polled.
Singleton {
    id: root

    property bool nightLight: false
    property bool darkMode: false
    property string colorScheme: ""
    property bool caffeine: false
    // Plasma's own volume popup (plasma-pa "VolumeOsd" + "MuteOsd" settings in plasmaparc).
    property bool plasmaVolumePopup: true

    // Night light: KDE and GNOME have their own; elsewhere we run a sunset tool
    // while it's on (hyprsunset, wlsunset or gammastep).
    readonly property string sunsetTool: Desktop.first(["hyprsunset", "wlsunset", "gammastep"])
    readonly property bool nightLightSupported: Desktop.isKde || (Desktop.isGnome && Desktop.has("gsettings")) || sunsetTool !== ""
    // Dark mode: Plasma colour schemes on KDE, the GTK/GNOME setting elsewhere.
    readonly property bool darkModeSupported: Desktop.isKde || Desktop.has("gsettings")

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
        if (Desktop.isKde)
            Quickshell.execDetached(["sh", "-c", "kwriteconfig6 --file kwinrc --group NightColor --key Active " + (on ? "true" : "false") + " && dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure"]);
        else if (Desktop.isGnome)
            Quickshell.execDetached(["gsettings", "set", "org.gnome.settings-daemon.plugins.color", "night-light-enabled", on ? "true" : "false"]);
        // otherwise the sunsetProcess below starts/stops with `nightLight`
    }

    function openNightLightSettings() {
        Desktop.run("nightlightsettings");
    }

    function setDarkMode(on) {
        darkMode = on;
        if (Desktop.isKde)
            Quickshell.execDetached(["plasma-apply-colorscheme", on ? Config.darkScheme : Config.lightScheme]);
        else
            Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", on ? "prefer-dark" : "default"]);
    }

    // Warm screen colours on desktops without a built-in night light.
    Process {
        running: root.nightLight && !Desktop.isKde && !Desktop.isGnome && root.sunsetTool !== ""
        command: root.sunsetTool === "hyprsunset" ? ["hyprsunset", "-t", "4000"] : root.sunsetTool === "wlsunset" ? ["wlsunset", "-T", "4001", "-t", "4000"] : ["gammastep", "-O", "4000"]
    }

    Process {
        id: reader
        command: Desktop.isKde ? ["sh", "-c", "kreadconfig6 --file kwinrc --group NightColor --key Active --default false; kreadconfig6 --file kdeglobals --group General --key ColorScheme --default BreezeLight; kreadconfig6 --file plasmaparc --group General --key VolumeOsd --default true"] : ["sh", "-c", "gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled 2>/dev/null || echo unknown; gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo default"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.trim().split("\n");
                if (Desktop.isKde) {
                    root.nightLight = (l[0] || "").trim() === "true";
                    root.colorScheme = (l[1] || "").trim();
                    root.darkMode = root.colorScheme.toLowerCase().indexOf("dark") !== -1;
                    root.plasmaVolumePopup = (l[2] || "true").trim() !== "false";
                } else {
                    if (Desktop.isGnome)
                        root.nightLight = (l[0] || "").trim() === "true";
                    root.colorScheme = (l[1] || "").replace(/'/g, "").trim();
                    root.darkMode = root.colorScheme === "prefer-dark";
                }
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
