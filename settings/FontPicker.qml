import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Font chooser: search, filter, popular picks, and a list of every installed
// font shown in its own style. "Get more fonts" installs a big free font pack.
Column {
    id: root
    width: parent ? parent.width : 500
    spacing: 10

    property string search: ""
    property string kind: "all"
    readonly property var allFonts: Qt.fontFamilies()

    readonly property var popular: ["Inter", "Noto Sans", "Roboto", "Open Sans", "Ubuntu", "Fira Sans", "Source Sans 3", "IBM Plex Sans", "Cantarell", "Lato", "Poppins", "Montserrat", "Nunito", "Quicksand", "Lexend", "DejaVu Sans", "Arial", "Verdana", "Georgia", "Times New Roman", "Impact", "Comic Sans MS", "Comic Neue", "Comic Shanns", "Comic Mono", "OpenDyslexic", "JetBrains Mono", "JetBrains Mono NL", "JetBrainsMono Nerd Font", "Fira Code", "Cascadia Code", "Hack", "Iosevka", "Source Serif 4", "Noto Serif", "IBM Plex Serif", "Playfair Display", "Pacifico", "Lobster", "Bebas Neue", "Webdings", "D050000L", "Symbola", "Font Awesome 6 Free"]
    readonly property var popularInstalled: popular.filter(f => allFonts.indexOf(f) !== -1)

    function kindOf(f) {
        const n = f.toLowerCase();
        if (/dings|dingbat|d050000l|symbol|awesome|emoji|icons|material design|joypixels|wingding/.test(n))
            return "symbols";
        if (/comic|opendyslexic|pacifico|lobster|bebas|marker|chalk|brush|script|hand|creep|bangers|impact/.test(n))
            return "fun";
        if (/mono|code|consol|courier|hack|iosevka|inconsolata|cascadia|terminal|fixed/.test(n))
            return "mono";
        if (/serif/.test(n) && !/sans/.test(n))
            return "serif";
        if (/garamond|times|georgia|libertin|crimson|caladea|junicode|gelasio|baskerville|bodoni|palatino|book/.test(n))
            return "serif";
        return "sans";
    }
    readonly property var shown: allFonts.filter(f => (kind === "all" || kindOf(f) === kind) && (search === "" || f.toLowerCase().indexOf(search) !== -1))

    // Current font preview
    Rectangle {
        width: parent.width
        height: 64
        radius: 12
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.06)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            x: 14
            width: parent.width - 28
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: "12:30  ·  Midnight City  ·  83%"
                color: Config.foreground
                font.family: Config.fontFamily !== "" ? Config.fontFamily : Qt.application.font.family
                font.pixelSize: 20
            }
            PillText {
                text: Config.fontFamily === "" ? "Plasma default (" + Qt.application.font.family + ")" : Config.fontFamily
                color: Config.subtle
                sizeFactor: 0.85
            }
        }
    }

    // Popular picks that you have installed
    Flow {
        width: parent.width
        spacing: 4
        SmallButton {
            label: "Plasma default"
            highlight: Config.fontFamily === ""
            onClicked: Config.setValue("font.family", "")
        }
        Repeater {
            model: root.popularInstalled
            delegate: SmallButton {
                required property var modelData
                label: modelData
                highlight: Config.fontFamily === modelData
                onClicked: Config.setValue("font.family", modelData)
            }
        }
    }

    // Search + filter
    TextBox {
        width: parent.width
        placeholder: "Search " + root.allFonts.length + " fonts…"
        onEdited: t => root.search = t.toLowerCase()
    }
    Choice {
        width: parent.width
        options: [{ label: "All", value: "all" }, { label: "Sans", value: "sans" }, { label: "Serif", value: "serif" }, { label: "Mono", value: "mono" }, { label: "Fun", value: "fun" }, { label: "Symbols", value: "symbols" }]
        current: root.kind
        onPicked: v => root.kind = v
    }

    // Every font, previewed in itself (only visible rows are drawn).
    Rectangle {
        width: parent.width
        height: 300
        radius: 12
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.04)
        border.width: 1
        border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08)
        clip: true

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 4
            model: root.shown
            boundsBehavior: Flickable.StopAtBounds
            delegate: Rectangle {
                required property var modelData
                readonly property bool current: Config.fontFamily === modelData
                width: list.width
                height: 40
                radius: 8
                color: current ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.3) : fm.containsMouse ? Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.08) : "transparent"
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 10
                    width: parent.width * 0.45
                    elide: Text.ElideRight
                    text: modelData
                    color: Config.foreground
                    font.family: modelData
                    font.pixelSize: 15
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: parent.width * 0.5
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    text: "12:30 · Midnight City"
                    color: Config.subtle
                    font.family: modelData
                    font.pixelSize: 13
                }
                MouseArea {
                    id: fm
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.setValue("font.family", modelData)
                }
            }
        }
        PillText {
            visible: root.shown.length === 0
            anchors.centerIn: parent
            text: "No fonts match"
            color: Config.subtle
        }
    }

    // More fonts
    Row {
        spacing: 8
        SmallButton {
            label: "Get more fonts"
            highlight: true
            onClicked: Quickshell.execDetached(Desktop.inTerminal(["sh", "-c", "cd \"$1\" && ./install.sh --fonts; echo; echo 'Done. Press Enter to close, then restart ArchPill to see the new fonts.'; read x", "sh", Updater.repo]))
        }
        SmallButton {
            label: "Restart ArchPill"
            onClicked: Updater.restart()
        }
    }
    PillText {
        width: parent.width
        wrapMode: Text.Wrap
        maximumLineCount: 6
        text: "\"Get more fonts\" opens a terminal and installs 100+ font packages: every JetBrains Mono, dozens of Nerd Fonts, Inter, Roboto, IBM Plex, OpenDyslexic, Comic Shanns, symbol fonts, and with yay/paru also Comic Sans, Webdings, Arial, Impact and popular Google fonts. It asks for your password. Then press Restart ArchPill. (Wingdings itself is Windows-only; Webdings and free symbol fonts are included instead.)"
        color: Config.subtle
        sizeFactor: 0.85
    }
}
