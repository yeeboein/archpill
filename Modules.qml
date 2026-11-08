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
        { id: "notifications", name: "Notifications", icon: "bell", desc: "Bell with how many notifications you haven't seen." },
        { id: "network", name: "Wi-Fi", icon: "wifi", desc: "Connection icon and network name." },
        { id: "bluetooth", name: "Bluetooth", icon: "bluetooth", desc: "Shows when Bluetooth is on / connected." },
        { id: "mic", name: "Microphone", icon: "mic", desc: "Appears only while your mic is muted." },
        { id: "weather", name: "Weather", icon: "cloud", desc: "Temperature (needs internet)." },
        { id: "cpu", name: "CPU", icon: "chip", desc: "Processor use in %." },
        { id: "ram", name: "RAM", icon: "chart", desc: "Memory use in %." },
        { id: "gpu", name: "GPU", icon: "gamepad", desc: "Graphics use in % (Intel: clock speed)." },
        { id: "temp", name: "CPU temperature", icon: "snowflake", desc: "Processor temperature." },
        { id: "separator", name: "Dot", icon: "dot", desc: "Separator: a small dot.", repeatable: true },
        { id: "separator:line", name: "Line", icon: "minus", desc: "Separator: a thin vertical line.", repeatable: true },
        { id: "separator:space", name: "Space", icon: "space", desc: "Separator: a little empty space.", repeatable: true },
        { id: "separator:wide", name: "Wide space", icon: "space", desc: "Separator: a bigger empty space.", repeatable: true }
    ]
    readonly property var available: all.map(m => m.id)

    readonly property var separators: all.filter(m => m.repeatable)
    readonly property var singles: all.filter(m => !m.repeatable)

    function info(id) {
        id = String(id).toLowerCase();
        for (let i = 0; i < all.length; i++)
            if (all[i].id === id)
                return all[i];
        return null;
    }

    function warnUnknown(name) {
        console.warn("[archpill] unknown module in config: \"" + name + "\" (available: " + available.join(", ") + ")");
    }
}
