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

    // ---- Wi-Fi menu ------------------------------------------------------------
    // [{ ssid, signal (0-100), secure, active, known }], strongest first.
    property var networks: []
    property var knownNames: []
    property bool scanning: lister.running
    property string busySsid: ""        // network we're connecting to
    property string message: ""         // last error / status for the menu

    // nmcli -t escapes ":" inside values as "\:"; split on the other colons.
    function splitTerse(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) {
                cur += line[++i];
            } else if (c === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += c;
            }
        }
        out.push(cur);
        return out;
    }

    function scan(rescan) {
        if (!lister.running) {
            lister.rescan = !!rescan;
            lister.running = true;
        }
    }

    function connectTo(net) {
        message = "";
        if (net.active)
            return;
        busySsid = net.ssid;
        if (net.known)
            connector.command = ["nmcli", "connection", "up", "id", net.ssid];
        else if (!net.secure)
            connector.command = ["nmcli", "device", "wifi", "connect", net.ssid];
        else {
            // needs a password: the small password window asks for it
            busySsid = "";
            PillState.wifiPasswordFor = net.ssid;
            return;
        }
        connector.running = true;
    }

    function connectWithPassword(ssid, password) {
        message = "";
        busySsid = ssid;
        connector.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        connector.running = true;
    }

    function disconnectFrom(net) {
        Quickshell.execDetached(["nmcli", "connection", "down", "id", net.ssid]);
        refreshSoon.restart();
        scanSoon.restart();
    }

    function forget(net) {
        Quickshell.execDetached(["nmcli", "connection", "delete", "id", net.ssid]);
        scanSoon.restart();
    }

    Process {
        id: lister
        property bool rescan: false
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show; echo '---'; nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan " + (rescan ? "yes" : "auto")]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("---\n");
                const known = [];
                (parts[0] || "").split("\n").forEach(l => {
                    const f = root.splitTerse(l);
                    if (f.length >= 2 && f[1] === "802-11-wireless")
                        known.push(f[0]);
                });
                root.knownNames = known;
                const seen = {};
                const nets = [];
                (parts[1] || "").split("\n").forEach(l => {
                    const f = root.splitTerse(l);
                    if (f.length < 4 || !f[1])
                        return;
                    const n = { ssid: f[1], active: f[0] === "*", signal: Number(f[2]) || 0, secure: f[3] !== "" && f[3] !== "--", known: known.indexOf(f[1]) !== -1 };
                    if (!seen[n.ssid] || n.active || n.signal > seen[n.ssid].signal)
                        seen[n.ssid] = n;
                });
                for (const k in seen)
                    nets.push(seen[k]);
                nets.sort((a, b) => (b.active - a.active) || (b.known - a.known) || (b.signal - a.signal));
                root.networks = nets;
            }
        }
    }

    Process {
        id: connector
        stderr: StdioCollector {
            id: connErr
        }
        onExited: code => {
            if (code !== 0)
                root.message = "Couldn't connect to " + root.busySsid + (connErr.text.indexOf("Secrets were required") !== -1 || connErr.text.indexOf("password") !== -1 ? " (wrong password?)" : "");
            root.busySsid = "";
            root.refresh();
            scanSoon.restart();
        }
    }

    Timer {
        id: scanSoon
        interval: 800
        onTriggered: root.scan(false)
    }

    function openSettings() {
        Desktop.run("netsettings");
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
