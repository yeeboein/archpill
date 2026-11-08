import QtQuick
import qs.components
import qs.services

Tile {
    icon: "palette"
    title: "ArchPill Settings"
    subtitle: "Make it yours"
    onClicked: {
        PillState.close();
        PillState.settingsOpen = true;
    }
}
