pragma Singleton

import QtQuick
import Quickshell

// Every widget you can add to the control centre.
// "wide" widgets take a full row, the others are half-width tiles.
// Each one lives in widgets/ and is hooked up in ControlCenter.qml.
Singleton {
    readonly property var all: [
        { id: "wifi", name: "Wi-Fi", wide: false },
        { id: "bluetooth", name: "Bluetooth", wide: false },
        { id: "dnd", name: "Do Not Disturb", wide: false },
        { id: "mic", name: "Microphone", wide: false },
        { id: "volume", name: "Volume", wide: true },
        { id: "brightness", name: "Brightness", wide: true },
        { id: "media", name: "Now Playing", wide: true },
        { id: "battery", name: "Battery", wide: true },
        { id: "clock", name: "Clock & Date", wide: true },
        { id: "power", name: "Power", wide: true }
    ]

    function info(id) {
        for (let i = 0; i < all.length; i++)
            if (all[i].id === id)
                return all[i];
        return null;
    }
}
