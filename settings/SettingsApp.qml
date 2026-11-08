import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// ArchPill Settings: a normal window (open it from the control centre's
// palette button, the "ArchPill Settings" tile, or
// `qs -c archpill ipc call archpill openSettings`).
//
// Every change is applied to the pill immediately and saved to
// ~/.config/archpill/config.json. While this window is open the pill stays
// visible so you can see what you're changing.
FloatingWindow {
    id: win

    title: "ArchPill Settings"
    implicitWidth: 900
    implicitHeight: 660
    minimumSize: Qt.size(640, 420)
    color: Qt.rgba(Config.background.r, Config.background.g, Config.background.b, 1)

    property string page: "pill"

    readonly property var pages: [
        { id: "pill", name: "Pill", icon: "pill" },
        { id: "control", name: "Control Centre", icon: "widgets" },
        { id: "appearance", name: "Appearance", icon: "palette" },
        { id: "behaviour", name: "Behaviour", icon: "mouse" },
        { id: "extras", name: "Music & More", icon: "music" },
        { id: "about", name: "Shortcuts & Reset", icon: "info" }
    ]

    onClosed: PillState.settingsOpen = false

    // ---- sidebar -------------------------------------------------------------
    Rectangle {
        id: sidebar
        width: 210
        height: parent.height
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.04)

        Column {
            x: 12
            y: 16
            width: parent.width - 24
            spacing: 4

            Row {
                spacing: 10
                leftPadding: 6
                bottomPadding: 14
                // ArchPill logo (only used here and as the app icon, never on the pill)
                Item {
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        anchors.fill: parent
                        anchors.margins: 0
                        source: Qt.resolvedUrl("../assets/logo.png")
                        sourceSize: Qt.size(80, 80)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }
                }
                PillText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "ArchPill"
                    font.weight: Font.Bold
                    sizeFactor: 1.3
                }
            }

            Repeater {
                model: win.pages
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool current: win.page === modelData.id
                    width: parent.width
                    height: 38
                    radius: 10
                    color: current ? Config.accent : nav.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08) : "transparent"
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                        spacing: 10
                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: modelData.icon
                            size: 17
                            color: parent.parent.current ? "#ffffff" : Config.foreground
                        }
                        PillText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            color: parent.parent.current ? "#ffffff" : Config.foreground
                        }
                    }
                    MouseArea {
                        id: nav
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            win.page = modelData.id;
                            flick.contentY = 0;
                        }
                    }
                }
            }
        }

        PillText {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
            x: 18
            width: parent.width - 36
            wrapMode: Text.Wrap
            maximumLineCount: 3
            text: "Changes save automatically."
            color: Config.subtle
            sizeFactor: 0.8
        }
    }

    // ---- page ------------------------------------------------------------------
    // Live pill preview, pinned above the Pill and Appearance pages.
    PillPreview {
        id: preview
        visible: win.page === "pill" || win.page === "appearance"
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.top: parent.top
        height: visible ? implicitHeight : 0
    }

    Flickable {
        id: flick
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.top: preview.bottom
        anchors.bottom: parent.bottom
        contentHeight: pageLoader.height + 60
        clip: true
        // Mouse wheel, touchpad and dragging all scroll (sliders and the
        // layout editor keep their own drags).
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        maximumFlickVelocity: 4000

        // A real mouse wheel scrolls in comfortable steps; touchpads use
        // Flickable's own smooth scrolling.
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse
            onWheel: e => {
                flick.cancelFlick();
                flick.contentY = Math.max(0, Math.min(flick.contentHeight - flick.height, flick.contentY - e.angleDelta.y));
            }
        }

        Loader {
            id: pageLoader
            x: 28
            y: 24
            width: flick.width - 56
            sourceComponent: {
                switch (win.page) {
                case "control":
                    return controlPage;
                case "appearance":
                    return appearancePage;
                case "behaviour":
                    return behaviourPage;
                case "extras":
                    return extrasPage;
                case "about":
                    return aboutPage;
                }
                return pillPage;
            }
        }
    }

    // Scrollbar (drag it, or click above/below the handle).
    Item {
        id: scrollTrack
        visible: flick.contentHeight > flick.height
        anchors.right: parent.right
        anchors.top: flick.top
        anchors.bottom: parent.bottom
        width: 14

        Rectangle {
            id: scrollHandle
            anchors.right: parent.right
            anchors.rightMargin: 3
            y: (flick.height - height) * (flick.contentY / Math.max(1, flick.contentHeight - flick.height))
            width: scrollMouse.containsMouse || scrollMouse.pressed ? 8 : 5
            height: Math.max(40, flick.height * (flick.height / flick.contentHeight))
            radius: width / 2
            color: Config.subtle
            opacity: scrollMouse.pressed ? 0.9 : 0.55
        }
        MouseArea {
            id: scrollMouse
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            function scrollTo(y) {
                const frac = Math.max(0, Math.min(1, (y - scrollHandle.height / 2) / (height - scrollHandle.height)));
                flick.contentY = frac * (flick.contentHeight - flick.height);
            }
            onPressed: mouse => scrollTo(mouse.y)
            onPositionChanged: mouse => {
                if (pressed)
                    scrollTo(mouse.y);
            }
        }
    }

    Component {
        id: pillPage
        PillPage {}
    }
    Component {
        id: controlPage
        ControlCenterPage {}
    }
    Component {
        id: appearancePage
        AppearancePage {}
    }
    Component {
        id: behaviourPage
        BehaviourPage {}
    }
    Component {
        id: extrasPage
        ExtrasPage {}
    }
    Component {
        id: aboutPage
        AboutPage {}
    }
}
