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

    function componentFor(id) {
        switch (id) {
        case "wifi":
            return wifiW;
        case "bluetooth":
            return bluetoothW;
        case "dnd":
            return dndW;
        case "mic":
            return micW;
        case "volume":
            return volumeW;
        case "brightness":
            return brightnessW;
        case "media":
            return mediaW;
        case "battery":
            return batteryW;
        case "clock":
            return clockW;
        case "power":
            return powerW;
        }
        console.warn("[archpill] unknown control centre widget: \"" + id + "\"");
        return null;
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
    readonly property var notAdded: WidgetRegistry.all.filter(w => list.indexOf(w.id) === -1)

    Component { id: wifiW; W.WifiTile {} }
    Component { id: bluetoothW; W.BluetoothTile {} }
    Component { id: dndW; W.DndTile {} }
    Component { id: micW; W.MicTile {} }
    Component { id: volumeW; W.VolumeSlider {} }
    Component { id: brightnessW; W.BrightnessSlider {} }
    Component { id: mediaW; W.MediaCard {} }
    Component { id: batteryW; W.BatteryCard {} }
    Component { id: clockW; W.ClockCard {} }
    Component { id: powerW; W.PowerCard {} }

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
            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                icon: PillState.editing ? "check" : "edit"
                size: 16
                onClicked: PillState.editing = !PillState.editing
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
                    readonly property bool wide: !info || info.wide

                    visible: !!info
                    width: wide ? flow.width : (flow.width - root.gap) / 2
                    height: Math.max(loader.item ? loader.item.implicitHeight : 0, PillState.editing ? 50 : 0)

                    Loader {
                        id: loader
                        width: parent.width
                        sourceComponent: slot.info ? root.componentFor(slot.modelData) : null
                        enabled: !PillState.editing
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
                text: root.notAdded.length > 0 ? "Add widgets" : "All widgets are added"
                color: Config.subtle
                sizeFactor: 0.9
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
