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

    // Unit hierarchies
    readonly property var unitsIECByte: ["KiB", "MiB", "GiB", "TiB", "PiB", "EiB"]
    readonly property var unitsMetricByte: ["KB", "MB", "GB", "TB", "PB", "EB"]
    readonly property var unitsIECBit: ["Kib", "Mib", "Gib", "Tib", "Pib", "Eib"]
    readonly property var unitsMetricBit: ["Kb", "Mb", "Gb", "Tb", "Pb", "Eb"]

    readonly property var units: ({
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
        "EiB": bytesPerEib,
        // Bit units (e.g. 1 Kb = 1000 bits = bytesPerKB / 8 bytes)
        "b": 1 / 8.0,
        "Kb": bytesPerKB / 8.0,
        "Kib": bytesPerKib / 8.0,
        "Mb": bytesPerMB / 8.0,
        "Mib": bytesPerMib / 8.0,
        "Gb": bytesPerGB / 8.0,
        "Gib": bytesPerGib / 8.0,
        "Tb": bytesPerTB / 8.0,
        "Tib": bytesPerTib / 8.0,
        "Pb": bytesPerPB / 8.0,
        "Pib": bytesPerPib / 8.0,
        "Eb": bytesPerEB / 8.0,
        "Eib": bytesPerEib / 8.0
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
        if (fromUnit === toUnit) {
            return value;
        }
        var bytes = value * units[fromUnit];
        return bytes / units[toUnit];
    }

    // Determine unit type and return ordered hierarchy.
    function getUnitHierarchy(unit) {
        switch (true) {
        case unit.endsWith('iB'):
            return unitsIECByte;
        case unit.endsWith('B'):
            return unitsMetricByte;
        case unit.endsWith('ib'):
            return unitsIECBit;
        case unit.endsWith('b'):
            return unitsMetricBit;
        default:
            throw new Error(`Invalid unit: ${unit}. Supported units: ` + Object.keys(units).join(", "));
        }
    }
}
