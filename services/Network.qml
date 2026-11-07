pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi state via NetworkManager's `nmcli` (ships with Plasma).
// No polling: it refreshes when asked (e.g. when the control centre opens)
// and listens to `nmcli monitor` only while someone is watching.
Singleton {
    id: root

    property bool available: true
    property bool wifiEnabled: false
    property string ssid: ""         // connected Wi-Fi network, "" if none
    property bool wired: false       // connected by cable
    property int watchers: 0         // >0 while a widget wants live updates

    function refresh() {
        if (query.running)
            queued = true;
        else
            query.running = true;
    }
    property bool queued: false

    function setWifi(on) {
        wifiEnabled = on; // optimistic
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        refreshSoon.restart();
    }

    function openSettings() {
        Quickshell.execDetached(["systemsettings", "kcm_networkmanagement"]);
    }

    Process {
        id: query
        command: ["sh", "-c", "nmcli -t radio wifi; nmcli -t -f TYPE,NAME connection show --active"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                root.wifiEnabled = (lines[0] || "").trim() === "enabled";
                let ssid = "", wired = false;
                for (let i = 1; i < lines.length; i++) {
                    const idx = lines[i].indexOf(":");
                    const type = lines[i].slice(0, idx), name = lines[i].slice(idx + 1);
                    if (type === "802-11-wireless" && !ssid)
                        ssid = name.replace(/\\:/g, ":");
                    else if (type === "802-3-ethernet")
                        wired = true;
                }
                root.ssid = ssid;
                root.wired = wired;
            }
        }
        onExited: code => {
            if (code === 127 && root.available) {
                root.available = false;
                console.warn("[archpill] nmcli not found - Wi-Fi widget disabled");
            }
            if (root.queued) {
                root.queued = false;
                running = true;
            }
        }
    }

    // Live updates only while watched.
    Process {
        running: root.watchers > 0 && root.available
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: refreshSoon.restart()
        }
    }

    Timer {
        id: refreshSoon
        interval: 400
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
