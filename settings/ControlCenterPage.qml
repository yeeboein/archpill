import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Control centre layout, the widget catalogue, app tiles and your own buttons.
Column {
    id: page
    width: parent ? parent.width : 600
    spacing: 22

    property string search: ""
    property string category: "All"
    property string appSearch: ""

    function addWidget(id) {
        if (Config.controlWidgets.indexOf(id) === -1)
            Config.setValue("controlCenter.widgets", Config.controlWidgets.concat([id]));
    }
    function has(id) {
        return Config.controlWidgets.indexOf(id) !== -1;
    }

    Section {
        title: "In your control centre"
        note: "Drag ⠿ to reorder. Small tiles sit two per row, wide widgets take a full row."
        LayoutEditor {
            items: Config.controlWidgets
            labelFor: id => {
                const i = WidgetRegistry.info(id);
                return i ? i.name : id + " (unknown)";
            }
            iconFor: id => {
                const i = WidgetRegistry.info(id);
                return i ? i.icon : "info";
            }
            noteFor: id => {
                const i = WidgetRegistry.info(id);
                return i ? (i.category + (i.wide ? " · wide" : " · tile")) : "Not found - remove it";
            }
            emptyText: "No widgets - add some below"
            onChanged: l => Config.setValue("controlCenter.widgets", l)
        }
        Item {
            width: parent.width
            height: 40
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                SmallButton {
                    label: "Reset to default"
                    onClicked: Config.resetValue("controlCenter.widgets")
                }
                SmallButton {
                    label: "Remove all"
                    onClicked: Config.setValue("controlCenter.widgets", [])
                }
            }
        }
    }

    Section {
        title: "Widget catalogue"
        note: WidgetRegistry.available.length + " widgets work on " + Desktop.niceName + ". Nothing runs until you add it."
        TextBox {
            placeholder: "Search widgets…"
            onEdited: t => page.search = t.toLowerCase()
        }
        Item {
            width: 1
            height: 6
        }
        Flow {
            width: parent.width
            spacing: 4
            Repeater {
                model: ["All"].concat(WidgetRegistry.categories)
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool current: page.category === modelData
                    width: ct.implicitWidth + 18
                    height: 26
                    radius: 13
                    color: current ? Config.foreground : "transparent"
                    border.width: current ? 0 : 1
                    border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.2)
                    PillText {
                        id: ct
                        anchors.centerIn: parent
                        text: modelData
                        sizeFactor: 0.85
                        color: parent.current ? Config.background : Config.foreground
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.category = modelData
                    }
                }
            }
        }
        Item {
            width: 1
            height: 6
        }
        Repeater {
            model: WidgetRegistry.available.filter(w => (page.category === "All" || w.category === page.category) && (page.search === "" || (w.name + " " + (w.desc || "") + " " + w.category).toLowerCase().indexOf(page.search) !== -1))
            delegate: SettingRow {
                required property var modelData
                label: modelData.name + (modelData.wide ? "  ·  wide" : "")
                description: modelData.desc || "One-click button (" + modelData.category + ")"
                controlWidth: 110
                SmallButton {
                    anchors.right: parent.right
                    label: page.has(modelData.id) ? "Added ✓" : "+ Add"
                    highlight: !page.has(modelData.id)
                    enabled: !page.has(modelData.id)
                    onClicked: page.addWidget(modelData.id)
                }
            }
        }
    }

    Section {
        title: "Apps"
        note: "Put any installed app in the control centre as a launcher tile."
        TextBox {
            placeholder: "Search apps…"
            onEdited: t => page.appSearch = t.toLowerCase()
        }
        Item {
            width: 1
            height: 6
        }
        Flow {
            width: parent.width
            spacing: 6
            Repeater {
                // Only list apps once you search, to keep this page light.
                model: page.appSearch.length < 1 ? [] : DesktopEntries.applications.values.filter(a => a && !a.noDisplay && (a.name + " " + (a.genericName || "")).toLowerCase().indexOf(page.appSearch) !== -1).slice(0, 40)
                delegate: AddChip {
                    required property var modelData
                    label: modelData.name + (page.has("app:" + modelData.id) ? " ✓" : "")
                    imageSource: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                    onAdd: page.addWidget("app:" + modelData.id)
                }
            }
        }
        PillText {
            visible: page.appSearch.length < 1
            text: "Type to search your apps (e.g. \"fire\" for Firefox)."
            color: Config.subtle
            sizeFactor: 0.9
        }
    }

    CustomButtons {}
}
