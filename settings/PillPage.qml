import QtQuick
import qs
import qs.components

// What's in the pill and in which order, plus per-module options.
Column {
    width: parent ? parent.width : 600
    spacing: 22

    Section {
        title: "In your pill"
        note: "Drag ⠿ to reorder (left = first). Changes show on the pill instantly."
        LayoutEditor {
            items: Config.modules
            labelFor: id => Modules.info(id) ? Modules.info(id).name : id
            iconFor: id => Modules.info(id) ? Modules.info(id).icon : "star"
            noteFor: id => Modules.info(id) ? Modules.info(id).desc : "Unknown module"
            emptyText: "The pill is empty - add modules below"
            onChanged: l => Config.setValue("pill.modules", l)
        }
    }

    Section {
        title: "Add to pill"
        Flow {
            width: parent.width
            spacing: 6
            Repeater {
                model: Modules.all.filter(m => Config.modules.indexOf(m.id) === -1)
                delegate: AddChip {
                    required property var modelData
                    label: modelData.name
                    icon: modelData.icon
                    tip: modelData.desc
                    onAdd: Config.setValue("pill.modules", Config.modules.concat([modelData.id]))
                }
            }
        }
        PillText {
            visible: Modules.all.every(m => Config.modules.indexOf(m.id) !== -1)
            text: "Every module is already in the pill."
            color: Config.subtle
        }
    }

    Section {
        title: "Clock"
        SettingRow {
            label: "Show date"
            Toggle {
                checked: Config.showDate
                onToggled: v => Config.setValue("clock.showDate", v)
            }
        }
        SettingRow {
            label: "Time format"
            Choice {
                options: [{ label: "14:32", value: "HH:mm" }, { label: "2:32 PM", value: "h:mm AP" }, { label: "14:32:05", value: "HH:mm:ss" }]
                current: Config.timeFormat
                onPicked: v => Config.setValue("clock.timeFormat", v)
            }
        }
        SettingRow {
            label: "Date format"
            controlWidth: 320
            Choice {
                options: [{ label: "Sun 8 Nov", value: "ddd d MMM" }, { label: "8 Nov", value: "d MMM" }, { label: "Nov 8", value: "MMM d" }, { label: "08/11", value: "dd/MM" }, { label: "Sunday", value: "dddd" }]
                current: Config.dateFormat
                onPicked: v => Config.setValue("clock.dateFormat", v)
            }
        }
    }

    Section {
        title: "Now Playing"
        SettingRow {
            label: "Show play / next / back buttons"
            description: "Off = click the song to get the controls in the big dropdown"
            Toggle {
                checked: Config.mediaShowControls
                onToggled: v => Config.setValue("media.showControls", v)
            }
        }
        SettingRow {
            label: "Show album art"
            Toggle {
                checked: Config.showArt
                onToggled: v => Config.setValue("media.showArt", v)
            }
        }
        SettingRow {
            label: "Song title width"
            NumberSlider {
                from: 60
                to: 400
                step: 10
                suffix: " px"
                value: Config.maxTitleWidth
                onMoved: v => Config.setValue("media.maxTitleWidth", v)
            }
        }
    }

    Section {
        title: "Other modules"
        SettingRow {
            label: "Volume: show percentage"
            Toggle {
                checked: Config.volumeShowPercent
                onToggled: v => Config.setValue("volume.showPercent", v)
            }
        }
        SettingRow {
            label: "Battery: show percentage"
            Toggle {
                checked: Config.batteryShowPercent
                onToggled: v => Config.setValue("battery.showPercent", v)
            }
        }
        SettingRow {
            label: "Wi-Fi: show network name"
            Toggle {
                checked: Config.networkShowName
                onToggled: v => Config.setValue("network.showName", v)
            }
        }
    }
}
