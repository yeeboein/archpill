pragma Singleton

import QtQuick
import Quickshell
import qs

// Colour themes offered in the settings app and the welcome tour.
Singleton {
    readonly property var all: [
        { name: "Midnight", c: { background: "#111114", foreground: "#f2f2f7", subtle: "#9a9aa5", accent: "#0a84ff" } },
        { name: "Graphite", c: { background: "#232326", foreground: "#ececf0", subtle: "#a0a0a8", accent: "#8e8e93" } },
        { name: "Pitch Black", c: { background: "#000000", foreground: "#ffffff", subtle: "#8e8e93", accent: "#636366" } },
        { name: "Ocean", c: { background: "#0b1d2e", foreground: "#e6f1ff", subtle: "#8aa4c0", accent: "#64d2ff" } },
        { name: "Forest", c: { background: "#102018", foreground: "#e8f5ec", subtle: "#8fb39c", accent: "#30d158" } },
        { name: "Sunset", c: { background: "#2a1215", foreground: "#fff1ea", subtle: "#c99a92", accent: "#ff9f0a" } },
        { name: "Grape", c: { background: "#1d1430", foreground: "#f3ecff", subtle: "#a596c4", accent: "#bf5af2" } },
        { name: "Rose", c: { background: "#2b1420", foreground: "#ffeef4", subtle: "#c896ab", accent: "#ff375f" } },
        { name: "Mint", c: { background: "#0f2423", foreground: "#e9fffb", subtle: "#88b5ae", accent: "#66d4cf" } },
        { name: "Light", c: { background: "#f5f5f7", foreground: "#1c1c1e", subtle: "#6e6e73", accent: "#0a84ff" } },
        { name: "Sand", c: { background: "#f4ede1", foreground: "#2b2420", subtle: "#857669", accent: "#c96f2d" } },
        { name: "Paper", c: { background: "#ffffff", foreground: "#111111", subtle: "#777777", accent: "#5e5ce6" } }
    ]

    function apply(theme) {
        const c = JSON.parse(JSON.stringify(Config.get("colors", {})));
        for (const k in theme.c)
            c[k] = theme.c[k];
        Config.setValue("colors", c);
    }

    function isCurrent(theme) {
        return Config.background.toString() === theme.c.background && Config.accent.toString() === theme.c.accent;
    }
}
