import QtQuick
import qs
import qs.components

// Colour setting: swatch + hex code + a row of quick colours.
Column {
    id: root
    property color value: "#000000"
    signal picked(string hex)

    width: parent ? parent.width : 260
    spacing: 6

    readonly property var quick: ["#111114", "#1c1c1e", "#2c2c2e", "#f2f2f7", "#ffffff", "#9a9aa5", "#0a84ff", "#5e5ce6", "#bf5af2", "#ff375f", "#ff453a", "#ff9f0a", "#ffd60a", "#30d158", "#64d2ff", "#66d4cf"]

    function hex(c) {
        const h = v => {
            const s = Math.round(v * 255).toString(16);
            return s.length < 2 ? "0" + s : s;
        };
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }

    Row {
        width: parent.width
        spacing: 8
        Rectangle {
            width: 32
            height: 32
            radius: 8
            color: root.value
            border.width: 1
            border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.3)
        }
        TextBox {
            width: parent.width - 40
            monospace: true
            text: root.hex(root.value)
            onAccepted: t => {
                const v = t.trim();
                if (/^#?[0-9a-fA-F]{6}$/.test(v))
                    root.picked(v[0] === "#" ? v : "#" + v);
            }
        }
    }
    Flow {
        width: parent.width
        spacing: 4
        Repeater {
            model: root.quick
            delegate: Rectangle {
                required property var modelData
                width: 18
                height: 18
                radius: 9
                color: modelData
                border.width: root.hex(root.value) === modelData ? 2 : 1
                border.color: root.hex(root.value) === modelData ? Config.accent : Qt.rgba(0.5, 0.5, 0.5, 0.5)
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.picked(modelData)
                }
            }
        }
    }
}
