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
    subtitle: confirming ? "Click again to confirm" : info && info.custom ? (info.custom.subtitle || "") : ""
    active: confirming

    // Restart / Shut down / Log out ask for a second click on desktops that
    // don't show their own confirmation screen (KDE does).
    property bool confirming: false
    Timer {
        id: confirmTimer
        interval: 3000
        onTriggered: root.confirming = false
    }
    imageSource: entry && entry.icon ? Quickshell.iconPath(entry.icon, true) : ""

    onClicked: {
        if (!info)
            return;
        if (info.confirm && !Desktop.isKde && !confirming) {
            confirming = true;
            confirmTimer.restart();
            return;
        }
        confirming = false;
        PillState.close();
        if (entry)
            entry.execute();
        else if (info.custom)
            Quickshell.execDetached(["sh", "-c", info.custom.command || "true"]);
        else if (info.run)
            Desktop.run(info.run);
        else if (info.action)
            Quickshell.execDetached(info.action);
    }
}
