pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ArchPill configuration.
//
// Settings are read from two JSON files and merged:
//   1. config.default.json  (shipped with ArchPill, never edit this one)
//   2. ~/.config/archpill/config.json  (your settings, only what you change)
//
// The user file is watched: save it and ArchPill updates live, no restart.
// If the user file has a JSON mistake, the last good settings are kept and
// a warning is printed to the log (`qs log -c archpill`).
Singleton {
    id: root

    readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/archpill"
    readonly property string userPath: configDir + "/config.json"

    property var defaults: ({})
    property var user: ({})
    readonly property var merged: merge(defaults, user)

    // ---- Pill ---------------------------------------------------------------
    readonly property var modules: get("pill.modules", ["clock", "media", "volume", "battery", "control"])
    readonly property int pillHeight: get("pill.height", 38)
    readonly property int pillMinWidth: get("pill.minWidth", 140)
    readonly property int pillMaxWidth: get("pill.maxWidth", 720)
    readonly property int pillRadius: get("pill.radius", 19)
    readonly property int pillPadding: get("pill.padding", 14)
    readonly property int pillSpacing: get("pill.spacing", 14)
    readonly property int topMargin: get("pill.topMargin", 6)
    readonly property string idleMode: get("pill.idleMode", "tiny") // "tiny" or "hidden"
    readonly property int triggerWidth: get("pill.triggerWidth", 420)
    readonly property int triggerHeight: Math.max(1, get("pill.triggerHeight", 3))
    readonly property int showDelay: get("pill.showDelay", 80)
    readonly property int hideDelay: get("pill.hideDelay", 450)
    readonly property string layer: get("pill.layer", "overlay") // "overlay" or "top"
    readonly property string monitor: get("pill.monitor", "")
    // What a click on an empty part of the pill opens: "control", "media" or "none".
    readonly property string clickAction: get("pill.clickAction", "control")

    // ---- Expanded views (music dropdown, control centre) -------------------
    readonly property int mediaWidth: get("expanded.mediaWidth", 400)
    readonly property int controlWidth: get("expanded.controlWidth", 380)
    readonly property int expandedMaxHeight: get("expanded.maxHeight", 640)
    readonly property int expandedRadius: get("expanded.radius", 26)
    readonly property bool closeOnLeave: get("expanded.closeOnLeave", true)
    readonly property int closeDelay: get("expanded.closeDelay", 700)

    // ---- Look ---------------------------------------------------------------
    readonly property color background: get("colors.background", "#111114")
    readonly property color foreground: get("colors.foreground", "#f2f2f7")
    readonly property color subtle: get("colors.subtle", "#9a9aa5")
    readonly property color accent: get("colors.accent", "#0a84ff")
    readonly property color good: get("colors.good", "#30d158")
    readonly property color warning: get("colors.warning", "#ff9f0a")
    readonly property color critical: get("colors.critical", "#ff453a")
    readonly property real opacity: Math.max(0, Math.min(1, get("opacity", 0.94)))
    readonly property color pillColor: Qt.rgba(background.r, background.g, background.b, opacity)

    readonly property string fontFamily: get("font.family", "")
    readonly property int fontSize: get("font.size", 12)
    readonly property int animDuration: Math.max(0, get("animation.duration", 180))

    // ---- Modules ------------------------------------------------------------
    readonly property string timeFormat: get("clock.timeFormat", "HH:mm")
    readonly property string dateFormat: get("clock.dateFormat", "ddd d MMM")
    readonly property bool showDate: get("clock.showDate", true)

    readonly property string preferredPlayer: get("media.preferredPlayer", "spotify")
    readonly property bool preferPlaying: get("media.preferPlaying", false)
    readonly property var ignoredPlayers: get("media.ignoredPlayers", [])
    readonly property bool showArt: get("media.showArt", true)
    readonly property bool mediaShowControls: get("media.showControls", false)
    readonly property int maxTitleWidth: get("media.maxTitleWidth", 170)

    readonly property int volumeStep: get("volume.step", 5)
    readonly property int maxVolume: get("volume.maxVolume", 100)
    readonly property bool volumeShowPercent: get("volume.showPercent", true)

    readonly property bool batteryShowPercent: get("battery.showPercent", true)
    readonly property int batteryLow: get("battery.lowThreshold", 20)

    readonly property var controlWidgets: get("controlCenter.widgets", ["wifi", "bluetooth", "dnd", "mic", "volume", "brightness", "media", "battery"])

    // ---- Helpers ------------------------------------------------------------

    // Read "a.b.c" from the merged config, or return the fallback.
    function get(path, fallback) {
        let node = root.merged;
        const parts = path.split(".");
        for (let i = 0; i < parts.length; i++) {
            if (node === null || node === undefined || typeof node !== "object")
                return fallback;
            node = node[parts[i]];
        }
        return (node === undefined || node === null) ? fallback : node;
    }

    // Deep-merge plain objects. Arrays and values from `b` replace those in `a`.
    function merge(a, b) {
        if (b === undefined || b === null)
            return a;
        if (typeof a !== "object" || typeof b !== "object" || Array.isArray(a) || Array.isArray(b) || a === null)
            return b;
        const out = {};
        for (const k in a)
            out[k] = a[k];
        for (const k in b)
            out[k] = (k in a) ? merge(a[k], b[k]) : b[k];
        return out;
    }

    function parse(text, label) {
        if (!text || text.trim() === "")
            return {};
        try {
            const obj = JSON.parse(text);
            return (obj && typeof obj === "object") ? obj : {};
        } catch (e) {
            console.warn("[archpill] " + label + " is not valid JSON, keeping previous settings: " + e);
            return null;
        }
    }

    // Change one setting and save it to ~/.config/archpill/config.json.
    // Only your own changes are stored there; defaults stay in config.default.json.
    function setValue(path, value) {
        const u = JSON.parse(JSON.stringify(root.user || {}));
        const parts = path.split(".");
        let node = u;
        for (let i = 0; i < parts.length - 1; i++) {
            if (typeof node[parts[i]] !== "object" || node[parts[i]] === null || Array.isArray(node[parts[i]]))
                node[parts[i]] = {};
            node = node[parts[i]];
        }
        node[parts[parts.length - 1]] = value;
        root.user = u; // update right away, the file watcher confirms it
        userFile.setText(JSON.stringify(u, null, 2) + "\n");
    }

    function reload() {
        userFile.reload();
    }

    FileView {
        id: defaultFile
        path: Quickshell.shellPath("config.default.json")
        blockLoading: true
        onLoaded: {
            const obj = root.parse(text(), "config.default.json");
            if (obj !== null)
                root.defaults = obj;
        }
        onLoadFailed: err => console.warn("[archpill] could not read config.default.json, using built-in defaults")
    }

    FileView {
        id: userFile
        path: root.userPath
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const obj = root.parse(text(), root.userPath);
            if (obj !== null) {
                root.user = obj;
                console.info("[archpill] loaded " + root.userPath);
            }
        }
        onLoadFailed: err => {
            console.info("[archpill] no user config at " + root.userPath + " (using defaults)");
            root.user = {};
        }
    }
}
