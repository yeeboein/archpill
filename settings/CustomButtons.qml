import QtQuick
import qs
import qs.components

// Make your own control-centre buttons: run a command, open a website or a folder.
Section {
    id: sec
    title: "Your own buttons"
    note: "Each button becomes a tile you can put in the control centre."

    property string kind: "website"
    property string newName: ""
    property string newTarget: ""
    property string newIcon: "web"

    readonly property var iconChoices: ["web", "star", "folder", "terminal", "code", "mail", "music", "gamepad", "home", "camera", "chart", "settings", "apps", "search", "clipboard", "timer", "calendar", "cloud", "bulb", "coffee", "lock", "power", "emoji", "palette"]

    function makeId() {
        return "c" + Date.now().toString(36);
    }
    function commandFor() {
        const t = newTarget.trim();
        if (kind === "website")
            return "xdg-open " + JSON.stringify(t.indexOf("://") === -1 ? "https://" + t : t);
        if (kind === "folder")
            return "xdg-open " + JSON.stringify(t.replace(/^~(?=\/|$)/, "$HOME"));
        return t;
    }
    function create() {
        if (newName.trim() === "" || newTarget.trim() === "")
            return;
        const b = { id: makeId(), name: newName.trim(), icon: newIcon, command: commandFor(), subtitle: kind === "command" ? "" : newTarget.trim() };
        Config.setValue("controlCenter.customButtons", (Config.customButtons || []).concat([b]));
        Config.setValue("controlCenter.widgets", Config.controlWidgets.concat(["custom:" + b.id]));
        nameBox.text = "";
        targetBox.text = "";
        newName = "";
        newTarget = "";
    }
    function removeButton(id) {
        Config.setValue("controlCenter.customButtons", Config.customButtons.filter(b => b.id !== id));
        Config.setValue("controlCenter.widgets", Config.controlWidgets.filter(w => w !== "custom:" + id));
    }

    // Existing buttons
    Repeater {
        model: Config.customButtons || []
        delegate: SettingRow {
            required property var modelData
            label: modelData.name
            description: modelData.command
            controlWidth: 200
            Row {
                anchors.right: parent.right
                spacing: 6
                SmallButton {
                    label: Config.controlWidgets.indexOf("custom:" + modelData.id) === -1 ? "+ Show" : "Shown ✓"
                    enabled: Config.controlWidgets.indexOf("custom:" + modelData.id) === -1
                    onClicked: Config.setValue("controlCenter.widgets", Config.controlWidgets.concat(["custom:" + modelData.id]))
                }
                SmallButton {
                    label: "Delete"
                    danger: true
                    onClicked: sec.removeButton(modelData.id)
                }
            }
        }
    }

    SettingRow {
        label: "New button type"
        controlWidth: 300
        Choice {
            options: [{ label: "Website", value: "website" }, { label: "Folder", value: "folder" }, { label: "Command", value: "command" }]
            current: sec.kind
            onPicked: v => {
                sec.kind = v;
                sec.newIcon = v === "website" ? "web" : v === "folder" ? "folder" : "terminal";
            }
        }
    }
    SettingRow {
        label: "Name"
        controlWidth: 300
        TextBox {
            id: nameBox
            placeholder: sec.kind === "website" ? "e.g. YouTube" : sec.kind === "folder" ? "e.g. Downloads" : "e.g. Update system"
            onEdited: t => sec.newName = t
        }
    }
    SettingRow {
        label: sec.kind === "website" ? "Web address" : sec.kind === "folder" ? "Folder" : "Command"
        description: sec.kind === "command" ? "Runs with sh, e.g.  konsole -e sudo pacman -Syu" : ""
        controlWidth: 300
        TextBox {
            id: targetBox
            monospace: sec.kind !== "website"
            placeholder: sec.kind === "website" ? "youtube.com" : sec.kind === "folder" ? "~/Downloads" : "konsole -e htop"
            onEdited: t => sec.newTarget = t
        }
    }
    SettingRow {
        label: "Icon"
        controlWidth: 300
        Flow {
            width: parent.width
            spacing: 2
            Repeater {
                model: sec.iconChoices
                delegate: Rectangle {
                    required property var modelData
                    width: 30
                    height: 30
                    radius: 8
                    color: sec.newIcon === modelData ? Config.accent : im.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.12) : "transparent"
                    Icon {
                        anchors.centerIn: parent
                        name: modelData
                        size: 16
                        color: sec.newIcon === modelData ? "#ffffff" : Config.foreground
                    }
                    MouseArea {
                        id: im
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sec.newIcon = modelData
                    }
                }
            }
        }
    }
    Item {
        width: parent.width
        height: 44
        SmallButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            label: "Create button"
            highlight: true
            enabled: sec.newName.trim() !== "" && sec.newTarget.trim() !== ""
            onClicked: sec.create()
        }
    }
}
