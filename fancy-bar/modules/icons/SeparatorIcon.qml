import QtQuick

Item {
    id: root

    // Public properties
    property color color: "#888888"
    property real strokeSize: 1
    property real length: 100
    property real dashLength: 2
    property real angle: 0  // 0 = horizontal, 90 = vertical (clockwise)
    property string lineType: "solid"  // solid, dotted, dashed, dotdash
    property real edgeRadius: 0  // Radius for line endings and dash caps
    property real spacing: 2  // Spacing multiplier for gaps between dots/dashes

    implicitWidth: Math.abs(Math.cos(angle * Math.PI / 180)) * length +
                   Math.abs(Math.sin(angle * Math.PI / 180)) * strokeSize
    implicitHeight: Math.abs(Math.sin(angle * Math.PI / 180)) * length +
                    Math.abs(Math.cos(angle * Math.PI / 180)) * strokeSize

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            ctx.save();

            // Translate to center and rotate
            ctx.translate(width / 2, height / 2);
            ctx.rotate(root.angle * Math.PI / 180);

            // Configure line style
            ctx.strokeStyle = root.color;
            ctx.lineWidth = root.strokeSize;
            ctx.lineCap = root.edgeRadius > 0 ? "round" : "butt";
            ctx.lineJoin = "round";

            // Set dash pattern based on line type
            const gap = root.spacing;
            // Dots: very short dash length to create dots
            const dotLength = root.dashLength / 10;
            // Offset to ensure elements aren't cutoff.
            let dashOffset = 0;

            switch(root.lineType) {
                case "dotted":
                    ctx.setLineDash([dotLength, gap]);
                    dashOffset = -root.length / 2 % (gap / 10 + gap);
                    break;
                case "dashed":
                    ctx.setLineDash([root.dashLength, gap]);
                    dashOffset = -root.length / 2 % (dashLength + gap);
                    break;
                case "dotdash":
                    ctx.setLineDash([dotLength, gap, root.dashLength, gap]);
                    dashOffset = -root.length / 2 % (gap / 10 + gap + dashLength + gap);
                    break;
                default:  // solid
                    ctx.setLineDash([]);
            }

            ctx.lineDashOffset = dashOffset;

            // Draw the line
            ctx.beginPath();
            ctx.moveTo(-root.length / 2, 0);
            ctx.lineTo(root.length / 2, 0);
            ctx.stroke();

            // Restore context state
            ctx.restore();
        }
    }
}
