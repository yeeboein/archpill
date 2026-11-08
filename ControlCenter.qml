import QtQuick
import qs
import qs.components
import qs.services
import qs.widgets as W

// Apple-style control centre, shown when the pill expands.
// Which widgets appear (and their order) is "controlCenter.widgets" in the
// config. Press the pencil to add, remove and reorder them right here.
Item {
    id: root

    readonly property var list: Config.controlWidgets
    readonly property int gap: 10

    implicitHeight: col.implicitHeight

    // id -> widget. Simple buttons (actions, apps, your own buttons)
    // all use ActionTile.
    readonly property var table: ({
            "wifi": wifiW,
            "bluetooth": bluetoothW,
            "airplane": airplaneW,
            "dnd": dndW,
            "mic": micW,
            "nightlight": nightW,
            "darkmode": darkW,
            "caffeine": caffeineW,
            "volume": volumeW,
            "micvolume": micVolumeW,
            "output": outputW,
            "mixer": mixerW,
            "brightness": brightnessW,
            "media": mediaW,
            "playpause": playPauseW,
            "nexttrack": nextTrackW,
            "battery": batteryW,
            "clock": clockW,
            "calendar": calendarW,
            "weather": weatherW,
            "stats": statsW,
            "sysinfo": sysinfoW,
            "timer": timerW,
            "clipboard": clipboardW,
            "power": powerW,
            "archpillsettings": settingsW,
            "update": updateW
        })

    function componentFor(id, info) {
        if (!info)
            return null;
        if (info.action || info.run || info.app || info.custom)
            return actionW;
        const c = table[id];
        if (!c)
            console.warn("[archpill] unknown control centre widget: \"" + id + "\"");
        return c || null;
    }

    // ---- editing the widget list (saved to config.json) ---------------------
    function save(newList) {
        Config.setValue("controlCenter.widgets", newList);
    }
    function removeAt(i) {
        const l = list.slice();
        l.splice(i, 1);
        save(l);
    }
    function move(i, delta) {
        const j = i + delta;
        if (j < 0 || j >= list.length)
            return;
        const l = list.slice();
        const t = l[i];
        l[i] = l[j];
        l[j] = t;
        save(l);
    }
    function add(id) {
        save(list.concat([id]));
    }
    property string category: WidgetRegistry.categories[0]
    readonly property var notAdded: WidgetRegistry.inCategory(category).filter(w => list.indexOf(w.id) === -1)

    Component { id: wifiW; W.WifiTile {} }
    Component { id: bluetoothW; W.BluetoothTile {} }
    Component { id: airplaneW; W.AirplaneTile {} }
    Component { id: dndW; W.DndTile {} }
    Component { id: micW; W.MicTile {} }
    Component { id: nightW; W.NightLightTile {} }
    Component { id: darkW; W.DarkModeTile {} }
    Component { id: caffeineW; W.CaffeineTile {} }
    Component { id: volumeW; W.VolumeSlider {} }
    Component { id: micVolumeW; W.MicVolumeSlider {} }
    Component { id: outputW; W.OutputCard {} }
    Component { id: mixerW; W.MixerCard {} }
    Component { id: brightnessW; W.BrightnessSlider {} }
    Component { id: mediaW; W.MediaCard {} }
    Component { id: playPauseW; W.PlayPauseTile {} }
    Component { id: nextTrackW; W.NextTrackTile {} }
    Component { id: batteryW; W.BatteryCard {} }
    Component { id: clockW; W.ClockCard {} }
    Component { id: calendarW; W.CalendarCard {} }
    Component { id: weatherW; W.WeatherCard {} }
    Component { id: statsW; W.StatsCard {} }
    Component { id: sysinfoW; W.SysInfoCard {} }
    Component { id: timerW; W.TimerCard {} }
    Component { id: clipboardW; W.ClipboardCard {} }
    Component { id: powerW; W.PowerCard {} }
    Component { id: settingsW; W.SettingsTile {} }
    Component { id: updateW; W.UpdateTile {} }
    Component { id: actionW; W.ActionTile {} }

    Column {
        id: col
        width: parent.width
        spacing: 12

        // Header
        Item {
            width: parent.width
            height: 30
            PillText {
                anchors.verticalCenter: parent.verticalCenter
                text: PillState.editing ? "Edit Control Centre" : "Control Centre"
                font.weight: Font.Bold
                sizeFactor: 1.2
            }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                // Opens the ArchPill settings app.
                IconButton {
                    icon: "palette"
                    size: 16
                    onClicked: {
                        PillState.close();
                        PillState.settingsOpen = true;
                    }
                }
                IconButton {
                    icon: PillState.editing ? "check" : "edit"
                    size: 16
                    onClicked: PillState.editing = !PillState.editing
                }
            }
        }

        // Update banner (only when a new version is waiting on GitHub)
        Rectangle {
            visible: Updater.available || Updater.status === "updating"
            width: parent.width
            height: 46
            radius: 14
            color: Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.22)
            border.width: 1
            border.color: Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.5)
            Icon {
                id: updIcon
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                name: "download"
                size: 18
                color: Config.accent
            }
            PillText {
                anchors.left: updIcon.right
                anchors.leftMargin: 10
                anchors.right: updBtn.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: Updater.status === "updating" ? "Updating… ArchPill will restart" : "Update available (" + Updater.behind + ")"
                font.weight: Font.DemiBold
            }
            Rectangle {
                id: updBtn
                visible: Updater.status !== "updating"
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: updText.implicitWidth + 24
                height: 30
                radius: 15
                color: Config.accent
                PillText {
                    id: updText
                    anchors.centerIn: parent
                    text: "Update"
                    color: "#ffffff"
                    font.weight: Font.DemiBold
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Updater.update()
                }
            }
        }

        // Widgets
        Flow {
            id: flow
            width: parent.width
            spacing: root.gap

            Repeater {
                model: root.list
                delegate: Item {
                    id: slot
                    required property var modelData
                    required property int index
                    readonly property var info: WidgetRegistry.info(modelData)
                    readonly property bool wide: !info || !!info.wide

                    // Hidden if this widget can't work on the current desktop.
                    visible: !!info && (!!info.app || !!info.custom || WidgetRegistry.supported(info))
                    width: !visible ? 0 : wide ? flow.width : (flow.width - root.gap) / 2
                    height: Math.max(loader.item ? loader.item.implicitHeight : 0, PillState.editing ? 50 : 0)

                    Loader {
                        id: loader
                        width: parent.width
                        sourceComponent: root.componentFor(slot.modelData, slot.info)
                        enabled: !PillState.editing
                        onLoaded: if ("info" in item) item.info = Qt.binding(() => slot.info)
                    }

                    // Edit overlay: move left/right and remove.
                    Rectangle {
                        anchors.fill: parent
                        visible: PillState.editing
                        radius: 18
                        color: Qt.rgba(Config.background.r, Config.background.g, Config.background.b, 0.9)
                        border.width: 1
                        border.color: Config.accent

                        // Widget name: above the buttons on tiles, at the left on wide widgets.
                        PillText {
                            x: slot.wide ? 14 : (parent.width - width) / 2
                            y: slot.wide ? (parent.height - height) / 2 : 4
                            text: slot.info ? slot.info.name : ""
                            sizeFactor: slot.wide ? 0.9 : 0.75
                            color: Config.subtle
                        }

                        Row {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: slot.wide ? 0 : 6
                            spacing: 2
                            IconButton {
                                icon: "chevron-left"
                                enabledAction: slot.index > 0
                                onClicked: root.move(slot.index, -1)
                            }
                            IconButton {
                                icon: "close"
                                onClicked: root.removeAt(slot.index)
                            }
                            IconButton {
                                icon: "chevron-right"
                                enabledAction: slot.index < root.list.length - 1
                                onClicked: root.move(slot.index, 1)
                            }
                        }
                    }
                }
            }
        }

        PillText {
            visible: root.list.length === 0 && !PillState.editing
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "No widgets yet - press the pencil to add some"
            color: Config.subtle
        }

        // Widget menu (edit mode)
        Column {
            visible: PillState.editing
            width: parent.width
            spacing: 8

            PillText {
                text: "Add widgets"
                color: Config.subtle
                sizeFactor: 0.9
            }
            // Category picker
            Flow {
                width: parent.width
                spacing: 4
                Repeater {
                    model: WidgetRegistry.categories
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool current: root.category === modelData
                        width: catText.implicitWidth + 16
                        height: 24
                        radius: 12
                        color: current ? Config.foreground : "transparent"
                        border.width: current ? 0 : 1
                        border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.2)
                        PillText {
                            id: catText
                            anchors.centerIn: parent
                            text: modelData
                            sizeFactor: 0.8
                            color: parent.current ? Config.background : Config.foreground
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.category = modelData
                        }
                    }
                }
            }
            PillText {
                visible: root.notAdded.length === 0
                text: "Everything in " + root.category + " is already added"
                color: Config.subtle
                sizeFactor: 0.85
            }
            Flow {
                width: parent.width
                spacing: 6
                Repeater {
                    model: root.notAdded
                    delegate: Rectangle {
                        required property var modelData
                        width: chipRow.implicitWidth + 20
                        height: 30
                        radius: 15
                        color: chipMouse.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.18) : Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.1)
                        Row {
                            id: chipRow
                            anchors.centerIn: parent
                            spacing: 4
                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "add"
                                size: 14
                                color: Config.accent
                            }
                            PillText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                sizeFactor: 0.9
                            }
                        }
                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.add(modelData.id)
                        }
                    }
                }
            }
            PillText {
                width: parent.width
                wrapMode: Text.Wrap
                maximumLineCount: 3
                text: "Want an app or your own button? Open ArchPill Settings (palette button) → Control Centre."
                color: Config.subtle
                sizeFactor: 0.8
            }
            Rectangle {
                width: resetText.implicitWidth + 24
                height: 30
                radius: 15
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.2)
                PillText {
                    id: resetText
                    anchors.centerIn: parent
                    text: "Reset to default"
                    sizeFactor: 0.9
                    color: Config.subtle
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const d = Config.defaults.controlCenter;
                        root.save(d && d.widgets ? d.widgets : ["wifi", "bluetooth", "dnd", "mic", "volume", "brightness", "media", "battery"]);
                    }
                }
            }
        }
    }
}
