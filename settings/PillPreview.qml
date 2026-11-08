import QtQuick
import qs
import qs.components

// Live preview of your pill on a desktop-like background, shown at the top
// of the Pill and Appearance pages. It's for looking only (not clickable).
Rectangle {
    id: root
    readonly property bool vertical: (Config.position === "left" || Config.position === "right") && Config.sideVertical
    implicitHeight: vertical ? Math.min(360, content.implicitHeight + Config.pillPadding * 2 + 40) : Config.pillHeight + 40
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0
            color: "#4a63b8"
        }
        GradientStop {
            position: 0.55
            color: "#b56b9e"
        }
        GradientStop {
            position: 1
            color: "#e3a96a"
        }
    }

    PillText {
        x: 10
        y: 6
        text: "Preview"
        color: "#ffffff"
        opacity: 0.8
        sizeFactor: 0.75
    }

    Item {
        id: pill
        anchors.centerIn: parent
        width: root.vertical ? Math.max(Config.pillHeight, content.implicitWidth + 16) : Math.min(root.width - 24, Math.max(Config.pillMinWidth, Math.min(Config.pillMaxWidth, content.implicitWidth + Config.pillPadding * 2)))
        height: root.vertical ? Math.min(root.height - 24, content.implicitHeight + Config.pillPadding * 2) : Config.pillHeight
        clip: true

        GlassBackground {
            anchors.fill: parent
            radius: Math.min(Config.pillRadius, Math.min(width, height) / 2)
        }
        PillContent {
            id: content
            anchors.centerIn: parent
            vertical: root.vertical
            enabled: false // preview only
        }
    }
}
