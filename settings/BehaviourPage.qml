import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// How the pill appears, hides and reacts.
Column {
    width: parent ? parent.width : 600
    Component.onCompleted: Plasma.refresh()
    spacing: 22

    Section {
        title: "Position"
        note: "Where the pill sits. It slides in from that edge, and the music player / control centre open towards the middle of the screen."
        Item {
            width: parent.width
            height: 190
            // A little screen with 8 spots to click.
            Rectangle {
                id: screenBox
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10
                width: 280
                height: 170
                radius: 12
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#4a63b8"
                    }
                    GradientStop {
                        position: 1
                        color: "#b56b9e"
                    }
                }
                border.width: 3
                border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.25)

                Repeater {
                    model: [
                        { pos: "top-left", x: 0, y: 0 }, { pos: "top", x: 1, y: 0 }, { pos: "top-right", x: 2, y: 0 },
                        { pos: "left", x: 0, y: 1 }, { pos: "right", x: 2, y: 1 },
                        { pos: "bottom-left", x: 0, y: 2 }, { pos: "bottom", x: 1, y: 2 }, { pos: "bottom-right", x: 2, y: 2 }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool current: Config.position === modelData.pos
                        readonly property bool vertical: modelData.pos === "left" || modelData.pos === "right"
                        width: vertical ? 14 : 56
                        height: vertical ? 40 : 14
                        radius: 7
                        x: modelData.x === 0 ? 10 : modelData.x === 2 ? screenBox.width - width - 10 : (screenBox.width - width) / 2
                        y: modelData.y === 0 ? 10 : modelData.y === 2 ? screenBox.height - height - 10 : (screenBox.height - height) / 2
                        color: current ? Config.accent : pm.containsMouse ? Qt.rgba(1, 1, 1, 0.6) : Qt.rgba(0, 0, 0, 0.45)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.5)
                        MouseArea {
                            id: pm
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Config.setValue("pill.position", modelData.pos)
                        }
                    }
                }
                PillText {
                    anchors.centerIn: parent
                    text: ({ "top": "Top", "top-left": "Top left", "top-right": "Top right", "bottom": "Bottom", "bottom-left": "Bottom left", "bottom-right": "Bottom right", "left": "Left side", "right": "Right side" })[Config.position] || Config.position
                    color: "#ffffff"
                    font.weight: Font.DemiBold
                }
            }
        }
        SettingRow {
            visible: Config.position === "left" || Config.position === "right"
            label: "Stand the pill up on the side"
            description: "Modules stack top to bottom; text stays upright and readable"
            Toggle {
                checked: Config.sideVertical
                onToggled: v => Config.setValue("pill.sideVertical", v)
            }
        }
        PillText {
            visible: Config.position.indexOf("bottom") === 0 || Config.position === "left" || Config.position === "right"
            width: parent.width
            wrapMode: Text.Wrap
            maximumLineCount: 2
            text: "Here the pill always stays over your taskbar/panels."
            color: Config.subtle
            sizeFactor: 0.85
        }
        SettingRow {
            label: "Gap from the screen edge"
            NumberSlider {
                from: 0
                to: 60
                suffix: " px"
                value: Config.topMargin
                onMoved: v => Config.setValue("pill.topMargin", v)
            }
        }
        SettingRow {
            visible: Config.position.indexOf("-") !== -1
            label: "Gap from the side (corners)"
            NumberSlider {
                from: 0
                to: 200
                step: 2
                suffix: " px"
                value: Config.edgeMargin
                onMoved: v => Config.setValue("pill.edgeMargin", v)
            }
        }
    }

    Section {
        title: "Notifications"
        note: "Show notifications in the pill: it grows to show the app, title and text, then shrinks back. Click to open, × to dismiss. Missed ones are in the control centre's Notifications widget."
        Component.onCompleted: Notifs.checkOwner()
        SettingRow {
            label: "Handled by: " + Notifs.ownerName + (Notifs.active ? " ✓" : "")
            description: Notifs.active ? "Notifications appear in the pill." : Desktop.isKde ? "Plasma shows them right now. Switch them to ArchPill (Plasma's panel restarts for a second)." : "Another app (" + Notifs.ownerName + ") shows them. Close it or remove it from autostart, and ArchPill takes over automatically."
            controlWidth: 240
            Row {
                anchors.right: parent.right
                spacing: 6
                SmallButton {
                    visible: Desktop.isKde && !Notifs.active
                    label: "Use ArchPill"
                    highlight: true
                    onClicked: Notifs.handOver()
                }
                SmallButton {
                    visible: Desktop.isKde && Notifs.active
                    label: "Give back to Plasma"
                    onClicked: Notifs.giveBack()
                }
                SmallButton {
                    label: "Check"
                    onClicked: Notifs.checkOwner()
                }
            }
        }
        PillText {
            visible: Notifs.handoverStatus !== ""
            width: parent.width
            wrapMode: Text.Wrap
            maximumLineCount: 3
            text: Notifs.handoverStatus
            color: Config.accent
            sizeFactor: 0.9
        }
        PillText {
            visible: Desktop.isKde && !Notifs.active
            width: parent.width
            wrapMode: Text.Wrap
            maximumLineCount: 6
            color: Config.subtle
            sizeFactor: 0.85
            text: "If the button doesn't work, do it by hand: right-click the little arrow in your system tray → Configure System Tray → Entries → Notifications → Disabled, then log out and back in. To undo, set it back to \"Shown when relevant\"."
        }
        SettingRow {
            label: "Show notifications in the pill"
            Toggle {
                checked: Config.notifShowInPill
                onToggled: v => Config.setValue("notifications.showInPill", v)
            }
        }
        SettingRow {
            label: "How long they stay"
            description: "Unless the app asks for a time. Urgent ones stay until you close them."
            NumberSlider {
                from: 2000
                to: 15000
                step: 500
                suffix: " ms"
                value: Config.notifDuration
                onMoved: v => Config.setValue("notifications.duration", v)
            }
        }
        SettingRow {
            label: "Width"
            NumberSlider {
                from: 260
                to: 640
                step: 10
                suffix: " px"
                value: Config.notifWidth
                onMoved: v => Config.setValue("notifications.width", v)
            }
        }
        SettingRow {
            label: "Do Not Disturb"
            description: "Notifications don't pop up (urgent ones still do); they still go to the history"
            Toggle {
                checked: PillState.dnd
                onToggled: v => PillState.dnd = v
            }
        }
        SettingRow {
            label: "Send a test notification"
            controlWidth: 120
            SmallButton {
                anchors.right: parent.right
                label: "Test"
                onClicked: Quickshell.execDetached(["notify-send", "-a", "ArchPill", "-i", Quickshell.shellPath("assets/logo.png"), "Hello from ArchPill 👋", "This is what notifications look like in the pill."])
            }
        }
    }

    Section {
        title: "Home (Windows) key"
        note: "Press the Windows / Super key on its own to open the pill."
        Component.onCompleted: Desktop.checkSuperKey()
        SettingRow {
            label: "Home (Windows) key opens the pill"
            description: Desktop.superKeyAutomatic ? "Sets it up in your " + Desktop.niceName + " config automatically" : "Needs a quick setup in " + Desktop.niceName + " (steps below)"
            Toggle {
                visible: Desktop.superKeyAutomatic
                checked: Desktop.superKeyEnabled
                onToggled: v => Desktop.setSuperKey(v)
            }
        }
        SettingRow {
            label: "It opens"
            controlWidth: 320
            Choice {
                options: [{ label: "Control centre", value: "control" }, { label: "Music", value: "media" }, { label: "Show pill", value: "pill" }]
                current: Config.superAction
                onPicked: v => Config.setValue("superKey.action", v)
            }
        }
        // Manual steps (KDE and others)
        Column {
            visible: !Desktop.superKeyAutomatic
            width: parent.width
            spacing: 6
            topPadding: 6
            bottomPadding: 6
            PillText {
                width: parent.width
                wrapMode: Text.Wrap
                maximumLineCount: 8
                color: Config.subtle
                sizeFactor: 0.9
                text: Desktop.isKde ? "1. Open System Settings → Keyboard → Shortcuts.\n2. Find \"Plasma Workspace\" → \"Activate Application Launcher\" and remove Meta from it (keep Alt+F1 if you like).\n3. Click \"Add New\" → \"Command or Script…\", paste the command below, and set the shortcut by pressing the Windows key on its own." : Desktop.isGnome ? "GNOME can't show ArchPill, so this isn't available." : "In your desktop's keyboard settings, bind the Super key (on its own, on release) to the command below."
            }
            Row {
                spacing: 6
                SmallButton {
                    label: "Copy command"
                    highlight: true
                    onClicked: Quickshell.clipboardText = Desktop.superKeyCommand
                }
                SmallButton {
                    visible: Desktop.isKde
                    label: "Open Shortcuts settings"
                    onClicked: Quickshell.execDetached(["systemsettings", "kcm_keys"])
                }
            }
        }
    }

    Section {
        title: "Showing & hiding"
        SettingRow {
            label: "Always show the pill"
            description: "Off = it hides until you touch the screen edge where it lives"
            Toggle {
                checked: Config.alwaysOpen
                onToggled: v => Config.setValue("pill.alwaysOpen", v)
            }
        }
        SettingRow {
            label: "While hidden, show"
            Choice {
                options: [{ label: "A tiny bar", value: "tiny" }, { label: "Nothing", value: "hidden" }]
                current: Config.idleMode
                onPicked: v => Config.setValue("pill.idleMode", v)
            }
        }
        SettingRow {
            label: "Hover area length"
            description: "How long the strip along the screen edge is"
            NumberSlider {
                from: 60
                to: 1600
                step: 20
                suffix: " px"
                value: Config.triggerWidth
                onMoved: v => Config.setValue("pill.triggerWidth", v)
            }
        }
        SettingRow {
            label: "Hover area thickness"
            NumberSlider {
                from: 1
                to: 20
                suffix: " px"
                value: Config.triggerHeight
                onMoved: v => Config.setValue("pill.triggerHeight", v)
            }
        }
        SettingRow {
            label: "Delay before showing"
            description: "Stops it popping up when you just pass the top edge"
            NumberSlider {
                from: 0
                to: 1000
                step: 10
                suffix: " ms"
                value: Config.showDelay
                onMoved: v => Config.setValue("pill.showDelay", v)
            }
        }
        SettingRow {
            label: "Delay before hiding"
            NumberSlider {
                from: 0
                to: 3000
                step: 50
                suffix: " ms"
                value: Config.hideDelay
                onMoved: v => Config.setValue("pill.hideDelay", v)
            }
        }
    }

    Section {
        title: "Clicking"
        SettingRow {
            label: "Click on an empty part of the pill opens"
            controlWidth: 320
            Choice {
                options: [{ label: "Control centre", value: "control" }, { label: "Music", value: "media" }, { label: "Nothing", value: "none" }]
                current: Config.clickAction
                onPicked: v => Config.setValue("pill.clickAction", v)
            }
        }
        SettingRow {
            label: "Close expanded views when the mouse leaves"
            Toggle {
                checked: Config.closeOnLeave
                onToggled: v => Config.setValue("expanded.closeOnLeave", v)
            }
        }
        SettingRow {
            label: "Safety margin"
            description: "Invisible border around the open control centre that still counts as \"on it\""
            NumberSlider {
                from: 0
                to: 120
                step: 5
                suffix: " px"
                value: Config.hoverMargin
                onMoved: v => Config.setValue("expanded.hoverMargin", v)
            }
        }
        SettingRow {
            label: "Close delay"
            NumberSlider {
                from: 100
                to: 5000
                step: 100
                suffix: " ms"
                value: Config.closeDelay
                onMoved: v => Config.setValue("expanded.closeDelay", v)
            }
        }
    }

    Section {
        title: "Volume popup"
        note: "When the volume changes (keyboard keys, panel, apps), the pill shows a volume bar for a moment."
        SettingRow {
            label: "Show volume changes in the pill"
            Toggle {
                checked: Config.osdEnabled
                onToggled: v => Config.setValue("osd.enabled", v)
            }
        }
        SettingRow {
            label: "How long it stays"
            NumberSlider {
                from: 500
                to: 5000
                step: 100
                suffix: " ms"
                value: Config.osdDuration
                onMoved: v => Config.setValue("osd.duration", v)
            }
        }
        SettingRow {
            label: "Width"
            NumberSlider {
                from: 160
                to: 600
                step: 10
                suffix: " px"
                value: Config.osdWidth
                onMoved: v => Config.setValue("osd.width", v)
            }
        }
        SettingRow {
            visible: Desktop.isKde
            label: "Plasma's own volume popup"
            description: Plasma.plasmaVolumePopup ? "On - you'll see both. Turn it off to only see the pill." : "Off - only the pill shows volume changes. (uninstall.sh turns it back on.)"
            controlWidth: 220
            SmallButton {
                anchors.right: parent.right
                label: Plasma.plasmaVolumePopup ? "Turn Plasma's off" : "Turn Plasma's back on"
                highlight: Plasma.plasmaVolumePopup
                onClicked: Plasma.setPlasmaVolumePopup(!Plasma.plasmaVolumePopup)
            }
        }
        SettingRow {
            label: "Try it"
            controlWidth: 160
            SmallButton {
                anchors.right: parent.right
                label: "Show the popup"
                onClicked: PillState.showOsd("volume")
            }
        }
    }

    Section {
        title: "Placement"
        SettingRow {
            label: "Layer"
            description: "Above everything covers fullscreen apps too; Normal hides behind fullscreen video and games (only for the top positions; at the bottom and sides it's always above the taskbar)"
            controlWidth: 300
            Choice {
                options: [{ label: "Above everything", value: "overlay" }, { label: "Normal", value: "top" }]
                current: Config.layer
                onPicked: v => Config.setValue("pill.layer", v)
            }
        }
        SettingRow {
            label: "Screens"
            controlWidth: 320
            Choice {
                options: {
                    const out = [{ label: "All screens", value: "" }];
                    for (let i = 0; i < Quickshell.screens.length; i++)
                        out.push({ label: Quickshell.screens[i].name, value: Quickshell.screens[i].name });
                    return out;
                }
                current: Config.monitor
                onPicked: v => Config.setValue("pill.monitor", v)
            }
        }
    }
}
