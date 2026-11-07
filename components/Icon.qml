import QtQuick
import qs

// Small built-in vector icons, coloured to match the theme.
// They don't depend on your icon theme, so they look right on the dark pill
// whether Plasma uses Breeze Light or Breeze Dark.
Image {
    id: root

    property string name: ""
    property color color: Config.foreground
    property int size: 16

    width: size
    height: size
    sourceSize: Qt.size(size, size)
    smooth: true
    cache: true

    // 24x24 path data (Material Design icons, Apache-2.0).
    readonly property var paths: ({
            "play": "M8 5v14l11-7z",
            "pause": "M6 19h4V5H6v14zm8-14v14h4V5h-4z",
            "next": "M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z",
            "previous": "M6 6h2v12H6zm3.5 6l8.5 6V6z",
            "volume-up": "M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z",
            "volume-down": "M18.5 12c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM5 9v6h4l5 5V4L9 9H5z",
            "volume-mute": "M7 9v6h4l5 5V4l-5 5H7z",
            "volume-off": "M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z",
            "bolt": "M7 2v11h3v9l7-12h-4l4-8z",
            "music": "M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"
        })

    function hex2(v) {
        const s = Math.round(v * 255).toString(16);
        return s.length < 2 ? "0" + s : s;
    }

    readonly property string svg: {
        const d = paths[name];
        if (!d)
            return "";
        const fill = "#" + hex2(color.r) + hex2(color.g) + hex2(color.b);
        return "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path fill='" + fill + "' fill-opacity='" + color.a + "' d='" + d + "'/></svg>";
    }

    source: svg ? "data:image/svg+xml;utf8," + encodeURIComponent(svg) : ""
}
