import QtQuick
import qs
import qs.modules as M

// The row of modules inside the pill ("pill.modules" in the config).
// Used by the real pill and by the live preview in ArchPill Settings.
Row {
    id: root

    property var modules: Config.modules
    // Which screen this pill is on (used by modules that open things).
    property string screenName: ""

    spacing: Config.pillSpacing

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
        }
        Modules.warnUnknown(name);
        return null;
    }

    Repeater {
        model: root.modules

        delegate: Loader {
            required property var modelData
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            sourceComponent: root.componentFor(modelData)
            visible: status === Loader.Ready && !!item && item.shown !== false
            onLoaded: {
                const id = String(modelData);
                if ("style" in item)
                    item.style = id.indexOf(":") !== -1 ? id.split(":")[1] : "dot";
                if ("kind" in item)
                    item.kind = id;
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
        id: statModule
        M.Stat {}
    }
    Component {
        id: separatorModule
        M.Separator {}
    }
}
