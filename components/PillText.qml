import QtQuick
import qs

// Text using the ArchPill colour and font settings.
Text {
    property real sizeFactor: 1.0
    color: Config.foreground
    font.pixelSize: Math.round(Config.fontSize * sizeFactor)
    font.family: Config.fontFamily !== "" ? Config.fontFamily : Qt.application.font.family
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    maximumLineCount: 1
    // A faint shadow keeps text readable on see-through glass.
    style: Config.styleMode === "glass" || Config.styleMode === "tinted" ? Text.Raised : Text.Normal
    styleColor: Qt.rgba(0, 0, 0, 0.45)
}
