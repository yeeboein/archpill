import QtQuick
import qs
import qs.modules as M

// The modules inside the pill ("pill.modules" in the config): a row, or a
// column when the pill stands vertically on a screen side.
// Used by the real pill and by the live preview in ArchPill Settings.
Grid {
    id: root

    property var modules: Config.modules
    // Vertical pill (screen side): modules stack top to bottom, text stays upright.
    property bool vertical: false
    rows: vertical ? -1 : 1
    columns: vertical ? 1 : -1
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter
    // Which screen this pill is on (used by modules that open things).
    property string screenName: ""

    rowSpacing: Math.max(6, Math.round(Config.pillSpacing * 0.7))
    columnSpacing: Config.pillSpacing

    // Name in config -> module. Separators can be added as often as you like:
    // "separator" (dot), "separator:line", "separator:space", "separator:wide".
    function componentFor(name) {
        name = String(name).toLowerCase();
        if (name === "separator" || name.indexOf("separator:") === 0)
            return separatorModule;
        if (name === "cpu" || name === "ram" || name === "gpu" || name === "temp")
            return statModule;
        switch (name) {
        case "clock":
            return clockModule;
        case "media":
            return mediaModule;
        case "volume":
            return volumeModule;
        case "battery":
            return batteryModule;
        case "control":
            return controlModule;
        case "network":
            return networkModule;
        case "bluetooth":
            return bluetoothModule;
        case "mic":
            return micModule;
        case "weather":
            return weatherModule;
        case "notifications":
            return bellModule;
        }
        Modules.warnUnknown(name);
        return null;
    }

    Repeater {
        model: root.modules

        delegate: Loader {
            required property var modelData
            sourceComponent: root.componentFor(modelData)
            visible: status === Loader.Ready && !!item && item.shown !== false
            onLoaded: {
                const id = String(modelData);
                if ("style" in item)
                    item.style = id.indexOf(":") !== -1 ? id.split(":")[1] : "dot";
                if ("kind" in item)
                    item.kind = id;
                if ("vertical" in item)
                    item.vertical = Qt.binding(() => root.vertical);
            }
        }
    }

    Component {
        id: clockModule
        M.Clock {}
    }
    Component {
        id: mediaModule
        M.Media {
            screenName: root.screenName
        }
    }
    Component {
        id: volumeModule
        M.Volume {}
    }
    Component {
        id: batteryModule
        M.Battery {}
    }
    Component {
        id: controlModule
        M.Control {
            screenName: root.screenName
        }
    }
    Component {
        id: networkModule
        M.Wifi {}
    }
    Component {
        id: bluetoothModule
        M.BluetoothStatus {}
    }
    Component {
        id: micModule
        M.Mic {}
    }
    Component {
        id: weatherModule
        M.WeatherTemp {}
    }
    Component {
        id: bellModule
        M.Bell {
            screenName: root.screenName
        }
    }
    Component {
        id: statModule
        M.Stat {}
    }
    Component {
        id: separatorModule
        M.Separator {}
    }
}
