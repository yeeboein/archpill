pragma Singleton

import QtQuick
import Quickshell

// The modules you can put in the pill (config: "pill.modules").
// Each one is a file in modules/ and is hooked up in Pill.qml (componentFor).
Singleton {
    readonly property var available: ["clock", "media", "volume", "battery"]

    function warnUnknown(name) {
        console.warn("[archpill] unknown module in config: \"" + name + "\" (available: " + available.join(", ") + ")");
    }
}
