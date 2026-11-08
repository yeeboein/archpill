import QtQuick
import qs
import qs.components
import qs.services

// Music players, sound, battery, weather and other details.
Column {
    width: parent ? parent.width : 600
    spacing: 22

    Section {
        title: "Music"
        SettingRow {
            label: "Preferred player"
            description: "Shown first when several are open (e.g. spotify, firefox, vlc)"
            TextBox {
                text: Config.preferredPlayer
                placeholder: "spotify"
                onAccepted: t => Config.setValue("media.preferredPlayer", t.trim())
            }
        }
        SettingRow {
            label: "Whatever is playing wins"
            description: "On = a playing player beats a paused preferred one"
            Toggle {
                checked: Config.preferPlaying
                onToggled: v => Config.setValue("media.preferPlaying", v)
            }
        }
        SettingRow {
            label: "Ignore players"
            description: "Comma separated, e.g. plasma-browser-integration, kdeconnect"
            TextBox {
                text: (Config.ignoredPlayers || []).join(", ")
                placeholder: "none"
                onAccepted: t => Config.setValue("media.ignoredPlayers", t.split(",").map(s => s.trim()).filter(s => s !== ""))
            }
        }
    }

    Section {
        title: "Sound & battery"
        SettingRow {
            label: "Volume step"
            description: "How much one scroll changes the volume"
            NumberSlider {
                from: 1
                to: 20
                suffix: "%"
                value: Config.volumeStep
                onMoved: v => Config.setValue("volume.step", v)
            }
        }
        SettingRow {
            label: "Maximum volume"
            description: "Above 100% can distort"
            NumberSlider {
                from: 100
                to: 150
                step: 5
                suffix: "%"
                value: Config.maxVolume
                onMoved: v => Config.setValue("volume.maxVolume", v)
            }
        }
        SettingRow {
            label: "Low battery warning at"
            NumberSlider {
                from: 5
                to: 50
                suffix: "%"
                value: Config.batteryLow
                onMoved: v => Config.setValue("battery.lowThreshold", v)
            }
        }
    }

    Section {
        title: "Weather"
        SettingRow {
            label: "Location"
            description: "City name, or leave empty to guess from your internet connection"
            TextBox {
                text: Config.weatherLocation
                placeholder: "e.g. London"
                onAccepted: t => Config.setValue("weather.location", t.trim())
            }
        }
        SettingRow {
            label: "Units"
            Choice {
                options: [{ label: "°C, km/h", value: "m" }, { label: "°F, mph", value: "u" }]
                current: Config.weatherUnits
                onPicked: v => Config.setValue("weather.units", v)
            }
        }
    }

    Section {
        title: Desktop.isKde ? "Plasma" : "Desktop"
        SettingRow {
            label: "Dark mode colour scheme"
            visible: Desktop.isKde
            description: "Used by the Dark Mode tile (see System Settings → Colours for names)"
            TextBox {
                text: Config.darkScheme
                onAccepted: t => Config.setValue("theme.darkScheme", t.trim())
            }
        }
        SettingRow {
            visible: Desktop.isKde
            label: "Light mode colour scheme"
            TextBox {
                text: Config.lightScheme
                onAccepted: t => Config.setValue("theme.lightScheme", t.trim())
            }
        }
        SettingRow {
            label: "Terminal app"
            description: "\"auto\" picks one you have (now: " + Desktop.terminal + ")"
            TextBox {
                text: Config.terminal
                monospace: true
                onAccepted: t => Config.setValue("apps.terminal", t.trim())
            }
        }
    }
}
