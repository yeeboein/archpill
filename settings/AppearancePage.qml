import QtQuick
import qs
import qs.components
import qs.services

// Colours, sizes, transparency, font and animation.
Column {
    id: page
    width: parent ? parent.width : 600
    spacing: 22

    readonly property var themes: Themes.all

    property string fontSearch: ""

    Section {
        title: "Theme"
        note: "Pick a starting point, then fine-tune the colours below."
        Flow {
            width: parent.width
            spacing: 8
            Repeater {
                model: page.themes
                delegate: Rectangle {
                    required property var modelData
                    width: 112
                    height: 58
                    radius: 14
                    color: modelData.c.background
                    border.width: Themes.isCurrent(modelData) ? 2 : 1
                    border.color: Themes.isCurrent(modelData) ? Config.accent : Qt.rgba(0.5, 0.5, 0.5, 0.4)
                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4
                            Repeater {
                                model: [modelData.c.foreground, modelData.c.subtle, modelData.c.accent]
                                delegate: Rectangle {
                                    required property var modelData
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: modelData
                                }
                            }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.name
                            color: modelData.c.foreground
                            font.pixelSize: 12
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Themes.apply(modelData)
                    }
                }
            }
        }
    }

    Section {
        title: "Colours"
        SettingRow {
            label: "Background"
            controlWidth: 320
            ColorPick {
                value: Config.background
                onPicked: h => Config.setValue("colors.background", h)
            }
        }
        SettingRow {
            label: "Text"
            controlWidth: 320
            ColorPick {
                value: Config.foreground
                onPicked: h => Config.setValue("colors.foreground", h)
            }
        }
        SettingRow {
            label: "Secondary text"
            controlWidth: 320
            ColorPick {
                value: Config.subtle
                onPicked: h => Config.setValue("colors.subtle", h)
            }
        }
        SettingRow {
            label: "Accent"
            description: "Active tiles, sliders, highlights"
            controlWidth: 320
            ColorPick {
                value: Config.accent
                onPicked: h => Config.setValue("colors.accent", h)
            }
        }
        SettingRow {
            label: "Good / charging"
            controlWidth: 320
            ColorPick {
                value: Config.good
                onPicked: h => Config.setValue("colors.good", h)
            }
        }
        SettingRow {
            label: "Warning"
            controlWidth: 320
            ColorPick {
                value: Config.warning
                onPicked: h => Config.setValue("colors.warning", h)
            }
        }
        SettingRow {
            label: "Critical / low battery"
            controlWidth: 320
            ColorPick {
                value: Config.critical
                onPicked: h => Config.setValue("colors.critical", h)
            }
        }
        SettingRow {
            label: "Opacity"
            description: "100% = solid. No blur is used, so lower values just let the desktop show through."
            NumberSlider {
                from: 30
                to: 100
                step: 1
                suffix: "%"
                value: Math.round(Config.opacity * 100)
                onMoved: v => Config.setValue("opacity", v / 100)
            }
        }
    }

    Section {
        title: "Pill size & shape"
        SettingRow {
            label: "Height"
            NumberSlider {
                from: 24
                to: 64
                suffix: " px"
                value: Config.pillHeight
                onMoved: v => Config.setValue("pill.height", v)
            }
        }
        SettingRow {
            label: "Corner radius"
            description: "Half the height = fully round"
            NumberSlider {
                from: 0
                to: 32
                suffix: " px"
                value: Config.pillRadius
                onMoved: v => Config.setValue("pill.radius", v)
            }
        }
        SettingRow {
            label: "Inner padding"
            NumberSlider {
                from: 4
                to: 40
                suffix: " px"
                value: Config.pillPadding
                onMoved: v => Config.setValue("pill.padding", v)
            }
        }
        SettingRow {
            label: "Space between modules"
            NumberSlider {
                from: 2
                to: 40
                suffix: " px"
                value: Config.pillSpacing
                onMoved: v => Config.setValue("pill.spacing", v)
            }
        }
        SettingRow {
            label: "Minimum width"
            NumberSlider {
                from: 40
                to: 600
                step: 10
                suffix: " px"
                value: Config.pillMinWidth
                onMoved: v => Config.setValue("pill.minWidth", v)
            }
        }
        SettingRow {
            label: "Maximum width"
            NumberSlider {
                from: 200
                to: 1600
                step: 20
                suffix: " px"
                value: Config.pillMaxWidth
                onMoved: v => Config.setValue("pill.maxWidth", v)
            }
        }
        SettingRow {
            label: "Gap from top of screen"
            NumberSlider {
                from: 0
                to: 40
                suffix: " px"
                value: Config.topMargin
                onMoved: v => Config.setValue("pill.topMargin", v)
            }
        }
    }

    Section {
        title: "Expanded views"
        SettingRow {
            label: "Corner radius"
            NumberSlider {
                from: 0
                to: 48
                suffix: " px"
                value: Config.expandedRadius
                onMoved: v => Config.setValue("expanded.radius", v)
            }
        }
        SettingRow {
            label: "Control centre width"
            NumberSlider {
                from: 300
                to: 720
                step: 10
                suffix: " px"
                value: Config.controlWidth
                onMoved: v => Config.setValue("expanded.controlWidth", v)
            }
        }
        SettingRow {
            label: "Music dropdown width"
            NumberSlider {
                from: 300
                to: 720
                step: 10
                suffix: " px"
                value: Config.mediaWidth
                onMoved: v => Config.setValue("expanded.mediaWidth", v)
            }
        }
        SettingRow {
            label: "Maximum height"
            description: "Taller content scrolls"
            NumberSlider {
                from: 300
                to: 1200
                step: 20
                suffix: " px"
                value: Config.expandedMaxHeight
                onMoved: v => Config.setValue("expanded.maxHeight", v)
            }
        }
    }

    Section {
        title: "Text"
        SettingRow {
            label: "Font"
            description: Config.fontFamily === "" ? "Using your Plasma font" : "Using " + Config.fontFamily
            controlWidth: 320
            Column {
                width: parent.width
                spacing: 6
                TextBox {
                    placeholder: "Search fonts…"
                    onEdited: t => page.fontSearch = t.toLowerCase()
                }
                Flow {
                    width: parent.width
                    spacing: 4
                    SmallButton {
                        label: "Plasma default"
                        highlight: Config.fontFamily === ""
                        onClicked: Config.setValue("font.family", "")
                    }
                    Repeater {
                        model: page.fontSearch.length < 1 ? [] : Qt.fontFamilies().filter(f => f.toLowerCase().indexOf(page.fontSearch) !== -1).slice(0, 12)
                        delegate: SmallButton {
                            required property var modelData
                            label: modelData
                            highlight: Config.fontFamily === modelData
                            onClicked: Config.setValue("font.family", modelData)
                        }
                    }
                }
            }
        }
        SettingRow {
            label: "Text size"
            NumberSlider {
                from: 8
                to: 20
                suffix: " px"
                value: Config.fontSize
                onMoved: v => Config.setValue("font.size", v)
            }
        }
    }

    Section {
        title: "Animation"
        SettingRow {
            label: "Animation speed"
            description: "Lower = snappier. 0 turns animations off (lightest)."
            NumberSlider {
                from: 0
                to: 600
                step: 10
                suffix: " ms"
                value: Config.animDuration
                onMoved: v => Config.setValue("animation.duration", v)
            }
        }
        SettingRow {
            label: "Quick presets"
            controlWidth: 300
            Choice {
                options: [{ label: "Off", value: 0 }, { label: "Fast", value: 120 }, { label: "Normal", value: 180 }, { label: "Relaxed", value: 320 }]
                current: Config.animDuration
                onPicked: v => Config.setValue("animation.duration", v)
            }
        }
    }
}
