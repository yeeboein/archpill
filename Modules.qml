pragma Singleton

import QtQuick
import Quickshell

// The modules you can put in the pill (config: "pill.modules").
// Each one is a file in modules/ and is hooked up in Pill.qml (componentFor).
Singleton {
    readonly property var all: [
        { id: "clock", name: "Clock", icon: "timer", desc: "Time and date." },
        { id: "media", name: "Now Playing", icon: "music", desc: "Song and artist. Click for the big music dropdown." },
        { id: "volume", name: "Volume", icon: "volume-up", desc: "Scroll to change, click to mute." },
        { id: "battery", name: "Battery", icon: "bolt", desc: "Charge level (hidden on desktops)." },
        { id: "control", name: "Control Centre Button", icon: "tune", desc: "Opens the control centre." },
        { id: "network", name: "Wi-Fi", icon: "wifi", desc: "Connection icon and network name." },
        { id: "bluetooth", name: "Bluetooth", icon: "bluetooth", desc: "Shows when Bluetooth is on / connected." },
        { id: "mic", name: "Microphone", icon: "mic", desc: "Appears only while your mic is muted." },
        { id: "weather", name: "Weather", icon: "cloud", desc: "Temperature (needs internet)." },
        { id: "separator", name: "Separator", icon: "dot", desc: "A small dot between modules." }
    ]
    readonly property var available: all.map(m => m.id)

    function info(id) {
        for (let i = 0; i < all.length; i++)
            if (all[i].id === id)
                return all[i];
        return null;
    }

    function warnUnknown(name) {
        console.warn("[archpill] unknown module in config: \"" + name + "\" (available: " + available.join(", ") + ")");
    }
}
