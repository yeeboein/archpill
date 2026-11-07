pragma Singleton

import QtQuick
import Quickshell

// The list of modules you can put in the pill (config: "pill.modules").
// Name in config  ->  file in modules/
Singleton {
    readonly property var available: ({
            "clock": "Clock.qml",
            "media": "Media.qml",
            "volume": "Volume.qml",
            "battery": "Battery.qml"
        })

    function fileFor(name) {
        const file = available[String(name).toLowerCase()];
        if (!file) {
            console.warn("[archpill] unknown module in config: \"" + name + "\" (available: " + Object.keys(available).join(", ") + ")");
            return "";
        }
        return Qt.resolvedUrl("modules/" + file);
    }
}
