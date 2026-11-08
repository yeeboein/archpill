import QtQuick
import qs
import qs.components

// A titled group of settings on a rounded card.
Column {
    property string title: ""
    property string note: ""
    default property alias rows: box.data

    width: parent ? parent.width : 400
    spacing: 8

    PillText {
        visible: text !== ""
        text: parent.title
        font.weight: Font.Bold
        sizeFactor: 1.1
    }
    PillText {
        visible: text !== ""
        width: parent.width
        text: parent.note
        color: Config.subtle
        sizeFactor: 0.9
        wrapMode: Text.Wrap
        maximumLineCount: 4
    }
    Rectangle {
        width: parent.width
        height: box.implicitHeight + 16
        radius: 14
        color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.05)
        border.width: 1
        border.color: Qt.rgba(Config.foreground.r, Config.foreground.g, Config.foreground.b, 0.06)

        Column {
            id: box
            x: 14
            y: 8
            width: parent.width - 28
            spacing: 2
        }
    }
}
