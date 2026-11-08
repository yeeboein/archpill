import QtQuick
import Quickshell
import qs
import qs.components

// Shortcuts, config file and reset.
Column {
    id: page
    width: parent ? parent.width : 600
    spacing: 22

    property bool confirmReset: false

    readonly property var commands: [
        { cmd: "toggleControlCenter", what: "Open / close the control centre" },
        { cmd: "toggleMedia", what: "Open / close the music dropdown" },
        { cmd: "openSettings", what: "Open this settings app" },
        { cmd: "toggle", what: "Keep the pill shown / let it hide" },
        { cmd: "playPause", what: "Play / pause music" },
        { cmd: "next", what: "Next song" },
        { cmd: "previous", what: "Previous song" }
    ]

    Section {
        title: "ArchPill"
        note: "A Dynamic Island-style pill for KDE Plasma, built with Quickshell. Your settings live in " + Config.userPath + " and are saved automatically."
        SettingRow {
            label: "Settings file"
            controlWidth: 300
            Row {
                anchors.right: parent.right
                spacing: 6
                SmallButton {
                    label: "Open file"
                    onClicked: Quickshell.execDetached(["xdg-open", Config.userPath])
                }
                SmallButton {
                    label: "Open folder"
                    onClicked: Quickshell.execDetached(["xdg-open", Config.configDir])
                }
            }
        }
        SettingRow {
            label: "Reset everything"
            description: "Go back to the default look and layout. Can't be undone."
            controlWidth: 220
            SmallButton {
                anchors.right: parent.right
                danger: true
                label: page.confirmReset ? "Click again to reset" : "Reset all settings"
                onClicked: {
                    if (page.confirmReset) {
                        Config.resetAll();
                        page.confirmReset = false;
                    } else {
                        page.confirmReset = true;
                    }
                }
            }
        }
    }

    Section {
        title: "Keyboard shortcuts"
        note: "System Settings → Keyboard → Shortcuts → Add New → Command or Script. Paste a command below and pick a key. \"Copy\" puts it on your clipboard."
        Repeater {
            model: page.commands
            delegate: SettingRow {
                required property var modelData
                readonly property string full: "qs -c archpill ipc call archpill " + modelData.cmd
                label: modelData.what
                description: full
                controlWidth: 90
                SmallButton {
                    anchors.right: parent.right
                    label: "Copy"
                    onClicked: Quickshell.clipboardText = parent.parent.full
                }
            }
        }
    }
}
