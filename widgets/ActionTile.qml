import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// A button tile. Used for:
//  - built-in action widgets (screenshot, lock, overview, ...)
//  - "app:<id>"     launch an installed app
//  - "custom:<id>"  run one of your own commands
Tile {
    id: root

    property var info: null
    readonly property var entry: info && info.app ? DesktopEntries.byId(info.app) : null

    icon: info ? info.icon : "star"
    title: info ? info.name : ""
    subtitle: info && info.custom ? (info.custom.subtitle || "") : ""
    imageSource: entry && entry.icon ? Quickshell.iconPath(entry.icon, true) : ""

    onClicked: {
        if (!info)
            return;
        PillState.close();
        if (entry)
            entry.execute();
        else if (info.custom)
            Quickshell.execDetached(["sh", "-c", info.custom.command || "true"]);
        else if (info.action)
            Quickshell.execDetached(info.action);
    }
}
