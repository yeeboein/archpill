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
        title: "Showing & hiding"
        SettingRow {
            label: "Always show the pill"
            description: "Off = it hides and slides down when you touch the top edge"
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
            label: "Hover area width"
            description: "How wide the strip at the top edge is"
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
            label: "Hover area height"
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
            description: "Above everything covers fullscreen apps too; Normal hides behind fullscreen video and games"
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
