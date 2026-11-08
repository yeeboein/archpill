import QtQuick
import qs

// The pill's background. Styles (config "style.mode"):
//   "solid"       plain colour (lightest)
//   "glass"       see-through "liquid glass": faint tint, glossy shine, bright edges
//   "blackglass"  solid black with liquid-glass edges and shine
//   "tinted"      glass tinted with your accent colour
//
// It's a fake glass look made from gradients and borders, with NO blur, so
// it stays cheap on weak GPUs.
Item {
    id: root
    property real radius: 0

    // Defaults to your chosen style; the settings previews pass their own.
    property string mode: Config.styleMode
    readonly property bool glassy: mode !== "solid"
    readonly property real shine: Config.glassShine
    readonly property real rim: Config.glassRim

    readonly property color baseColor: {
        const b = Config.background, a = Config.accent;
        switch (mode) {
        case "glass":
            return Qt.rgba(b.r, b.g, b.b, Config.glassTint);
        case "blackglass":
            return Qt.rgba(0, 0, 0, Math.max(0.85, Config.opacity));
        case "tinted":
            return Qt.rgba(a.r * 0.55 + b.r * 0.45, a.g * 0.55 + b.g * 0.45, a.b * 0.55 + b.b * 0.45, Config.glassTint);
        }
        return Config.pillColor;
    }

    // Base fill
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.baseColor
        border.width: root.glassy ? 0 : 1
        border.color: Qt.rgba(1, 1, 1, 0.06)
    }

    // Glossy shine: bright at the top, fading out, a little glow at the bottom.
    Rectangle {
        visible: root.glassy && root.shine > 0
        anchors.fill: parent
        radius: root.radius
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(1, 1, 1, 0.26 * root.shine)
            }
            GradientStop {
                position: 0.45
                color: Qt.rgba(1, 1, 1, 0.04 * root.shine)
            }
            GradientStop {
                position: 0.8
                color: Qt.rgba(1, 1, 1, 0.0)
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(1, 1, 1, 0.08 * root.shine)
            }
        }
    }

    // Outer glass edge
    Rectangle {
        visible: root.glassy && root.rim > 0
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.45 * root.rim)
    }

    // Inner edge: a second, softer line just inside, gives the "thick glass" look.
    Rectangle {
        visible: root.glassy && root.rim > 0
        anchors.fill: parent
        anchors.margins: 1.5
        radius: Math.max(0, root.radius - 1.5)
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.14 * root.rim)
    }

    // Specular highlight along the top edge.
    Rectangle {
        visible: root.glassy && root.rim > 0 && root.height > 10
        x: Math.max(root.radius, 6)
        y: 1.5
        width: root.width - x * 2
        height: 1.2
        radius: 1
        color: Qt.rgba(1, 1, 1, 0.55 * root.rim)
    }
}
