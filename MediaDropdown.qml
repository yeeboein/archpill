import QtQuick
import qs.components

// The big music dropdown you get by clicking the song in the pill.
Item {
    implicitHeight: view.implicitHeight

    MediaView {
        id: view
        width: parent.width
        big: true
    }
}
