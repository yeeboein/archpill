import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

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
        { cmd: "welcome", what: "Show the welcome tour" },
        { cmd: "toggle", what: "Keep the pill shown / let it hide" },
        { cmd: "playPause", what: "Play / pause music" },
        { cmd: "next", what: "Next song" },
        { cmd: "previous", what: "Previous song" }
    ]

    Row {
        spacing: 16
        Item {
            width: 96
            height: 96
            Image {
                anchors.fill: parent
                anchors.margins: 0
                source: Qt.resolvedUrl("../assets/logo.png")
                sourceSize: Qt.size(192, 192)
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            PillText {
                text: "ArchPill"
                font.weight: Font.Bold
                sizeFactor: 2
            }
            PillText {
                text: "Your Dynamic Island for KDE Plasma"
                color: Config.subtle
            }
        }
    }

    Section {
        title: "ArchPill"
        note: "A Dynamic Island-style pill for KDE Plasma, built with Quickshell. Your settings live in " + Config.userPath + " and are saved automatically."
        SettingRow {
            label: "Welcome tour"
            description: "The setup walkthrough from the first start"
            controlWidth: 220
            SmallButton {
                anchors.right: parent.right
                label: "Show it again"
                onClicked: PillState.welcomeOpen = true
            }
        }
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
        title: "Updates"
        note: Updater.repo !== "" ? "ArchPill updates from GitHub using your copy in " + Updater.repo + "." : ""
        SettingRow {
            label: Updater.status === "checking" ? "Checking…" : Updater.status === "updating" ? "Updating… ArchPill will restart" : Updater.status === "error" ? Updater.error : Updater.status === "norepo" ? "Updates need ArchPill installed with git clone" : Updater.available ? Updater.behind + (Updater.behind === 1 ? " update available" : " updates available") : Updater.lastCheck > 0 ? "You're up to date ✓" : "Not checked yet"
            description: Updater.available ? "What's new:\n• " + Updater.changes.join("\n• ") : ""
            controlWidth: 240
            Row {
                anchors.right: parent.right
                spacing: 6
                SmallButton {
                    label: "Check now"
                    enabled: Updater.status !== "checking" && Updater.status !== "updating"
                    onClicked: Updater.check()
                }
                SmallButton {
                    visible: Updater.available
                    label: "Update"
                    highlight: true
                    enabled: Updater.status !== "updating"
                    onClicked: Updater.update()
                }
            }
        }
        SettingRow {
            label: "Check automatically"
            description: "A quick check every few hours (needs internet)"
            Toggle {
                checked: Config.updateAutoCheck
                onToggled: v => Config.setValue("updates.autoCheck", v)
            }
        }
        SettingRow {
            label: "Notify me about updates"
            Toggle {
                checked: Config.updateNotify
                onToggled: v => Config.setValue("updates.notify", v)
            }
        }
        SettingRow {
            label: "Check every"
            NumberSlider {
                from: 1
                to: 48
                suffix: " h"
                value: Config.updateCheckHours
                onMoved: v => Config.setValue("updates.checkHours", v)
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
