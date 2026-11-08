pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Weather from wttr.in. Fetched only when a weather widget is shown,
// and at most every 30 minutes.
Singleton {
    id: root

    property string icon: ""
    property string temp: ""
    property string condition: ""
    property string place: ""
    property string feels: ""
    property string wind: ""
    property bool ok: false
    property bool loading: fetcher.running
    property real lastFetch: 0

    function refresh(force) {
        if (fetcher.running)
            return;
        if (!force && ok && Date.now() - lastFetch < 30 * 60 * 1000)
            return;
        fetcher.running = true;
    }

    Connections {
        target: Config
        function onWeatherLocationChanged() {
            root.refresh(true);
        }
    }

    Process {
        id: fetcher
        command: ["curl", "-sf", "--max-time", "10", "https://wttr.in/" + encodeURIComponent(Config.weatherLocation) + "?" + Config.weatherUnits + "&format=%c|%t|%C|%l|%f|%w"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("|");
                if (f.length >= 4 && text.indexOf("<") === -1) {
                    root.icon = f[0].trim();
                    root.temp = f[1].trim();
                    root.condition = f[2].trim();
                    root.place = f[3].trim();
                    root.feels = (f[4] || "").trim();
                    root.wind = (f[5] || "").trim();
                    root.ok = true;
                    root.lastFetch = Date.now();
                } else {
                    root.ok = false;
                }
            }
        }
        onExited: code => {
            if (code !== 0)
                root.ok = false;
        }
    }
}
