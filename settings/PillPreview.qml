import QtQuick
import qs
import qs.components

// Live preview of your pill on a desktop-like background, shown at the top
// of the Pill and Appearance pages. It's for looking only (not clickable).
Rectangle {
    id: root
    implicitHeight: Config.pillHeight + 40
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
        width: Math.min(root.width - 24, Math.max(Config.pillMinWidth, Math.min(Config.pillMaxWidth, content.implicitWidth + Config.pillPadding * 2)))
        height: Config.pillHeight
        clip: true

        GlassBackground {
            anchors.fill: parent
            radius: Math.min(Config.pillRadius, height / 2)
        }
        PillContent {
            id: content
            anchors.centerIn: parent
            enabled: false // preview only
        }
    }
}
