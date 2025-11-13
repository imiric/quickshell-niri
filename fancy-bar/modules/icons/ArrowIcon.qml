import QtQuick

Item {
    id: root
    property real scale: 1
    property color color: "white"
    // Rotation angle (0-360 degrees)
    property real angle: 0

    width: scale
    height: scale

    // Icon from TDesign Icons by TDesign
    // https://github.com/Tencent/tdesign-icons/blob/main/LICENSE
    // Converted to 2D canvas by Grok Code Fast 1.
    // I'm not using the original SVG with Shape since I had issues positioning
    // the rotated icon.

    Canvas {
        anchors.centerIn: parent
        width: root.width
        height: root.height

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.antialiasing = false;

            // Center the canvas coordinate system at the middle of the icon's
            // bounding box
            ctx.save();
            ctx.translate(width / 2, height / 2);
            ctx.rotate(root.angle * Math.PI / 180);
            // Calculate scale to fit the path's implicit bounding box
            // (x:4.5-19.5 = width 15; y:2-22 = height 20) within the canvas
            // bounds
            const pathWidth = 15;  // Implicit bbox width from path
            const pathHeight = 20; // Implicit bbox height from path
            const s = Math.min(width / pathWidth, height / pathHeight);
            ctx.scale(s, s);
            // Translate to offset the path's center (original SVG center at
            // (12,12)) to (0,0) in the centered/rotated space
            ctx.translate(-12, -12);

            // Draw the path
            ctx.fillStyle = root.color;
            ctx.beginPath();
            ctx.moveTo(15, 12);
            ctx.lineTo(19.5, 12);
            ctx.lineTo(12, 2);
            ctx.lineTo(4.5, 12);
            ctx.lineTo(9, 12);
            ctx.lineTo(9, 22);
            ctx.lineTo(15, 22);
            ctx.closePath();
            ctx.fill();
            ctx.restore();
        }
    }
}
