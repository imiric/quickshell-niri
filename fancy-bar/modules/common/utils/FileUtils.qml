pragma Singleton
import Quickshell

Singleton {
    id: root

    // Binary unit factors: 1 KiB = 1024 bytes, etc.
    readonly property int bytesPerKib: 1024
    readonly property int bytesPerMib: 1024 ** 2
    readonly property int bytesPerGib: 1024 ** 3
    readonly property int bytesPerTib: 1024 ** 4
    readonly property int bytesPerPib: 1024 ** 5
    readonly property int bytesPerEib: 1024 ** 6

    // Decimal unit factors: 1 KB = 1000 bytes, etc.
    readonly property int bytesPerKB: 1000
    readonly property int bytesPerMB: 1000 ** 2
    readonly property int bytesPerGB: 1000 ** 3
    readonly property int bytesPerTB: 1000 ** 4
    readonly property int bytesPerPB: 1000 ** 5
    readonly property int bytesPerEB: 1000 ** 6

    property var units: ({
        "B": 1,
        "KB": bytesPerKB,
        "KiB": bytesPerKib,
        "MB": bytesPerMB,
        "MiB": bytesPerMib,
        "GB": bytesPerGB,
        "GiB": bytesPerGib,
        "TB": bytesPerTB,
        "TiB": bytesPerTib,
        "PB": bytesPerPB,
        "PiB": bytesPerPib,
        "EB": bytesPerEB,
        "EiB": bytesPerEib
    })

    /**
     * Converts a value from one file size unit to another.
     *
     * @param {number} value - The numeric value to convert.
     * @param {string} fromUnit - The unit of the input value (e.g., "KB", "MB").
     * @param {string} toUnit - The unit to convert to (e.g., "MB", "GB").
     * @returns {number} The converted value.
     */
    function convertSizeUnit(value, fromUnit, toUnit) {
        if (!units.hasOwnProperty(fromUnit) || !units.hasOwnProperty(toUnit)) {
            throw new Error("Invalid unit. Supported units: " + Object.keys(units).join(", "));
        }
        var bytes = value * units[fromUnit];
        return bytes / units[toUnit];
    }
}
