pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root

    // Available interfaces: Map of Types.Network keys to arrays of interface names
    property var interfaces: new Map()
    property string activeInterface: ""
    property int networkType: -1

    // Common
    property real rateUp: 0.0  // Bytes/s
    property real rateDown: 0.0
    property var lanIPs: []  // List of IP strings
    property string wanIP: ""

    // Wireless
    property string ssid: ""
    property int frequency: 0
    property int signalStrength: 0 // dBm
    property real bitrateTx: 0.0  // Mbps
    property real bitrateRx: 0.0  // Mbps

    // Wired
    property int linkSpeed: 0  // Mbps

    // Internal state for rate calculations
    property var tx: 0
    property var rx: 0

    // Fixed 1000ms timer for rates (not configurable, to ensure /s calc)
    Timer {
        id: rateTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateRates()
    }

    // Configurable timers
    Timer {
        id: infoTimer
        interval: Config.data.network.infoUpdateInterval * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateInfo()
    }

    Timer {
        id: externalTimer
        interval: Config.data.network.externalUpdateInterval * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateExternal()
    }

    FileView {
        id: txBytesView
        path: root.activeInterface ? "/sys/class/net/" + root.activeInterface + "/statistics/tx_bytes" : ""
        preload: false
        onLoadFailed: (error) => console.log("Network Service: Failed to load tx_bytes:", error)
    }

    FileView {
        id: rxBytesView
        path: root.activeInterface ? "/sys/class/net/" + root.activeInterface + "/statistics/rx_bytes" : ""
        preload: false
        onLoadFailed: (error) => console.log("Network Service: Failed to load rx_bytes:", error)
    }

    FileView {
        id: linkSpeedView
        path: root.activeInterface && root.networkType === Types.Network.Wired ? "/sys/class/net/" + root.activeInterface + "/speed" : ""
        preload: false
        onLoadFailed: (error) => console.log("Network Service: Failed to load link speed:", error)
    }

    Process {
        id: listInterfacesProc
        command: [
            "find", "/sys/class/net", "-mindepth", "1", "-maxdepth", "1", "-type", "l",
            "-exec", "sh", "-c", `n=$(basename {}); [ -d {}/wireless ] || [ -L {}/phy80211 ] && echo "$n wireless" || { [ -d {}/device ] && echo "$n wired" || echo "$n virtual"; }`, `\;`
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n');
                const result = new Map([
                    [Types.Network.Wired, []],
                    [Types.Network.Wireless, []],
                    [Types.Network.Virtual, []],
                ]);
                for (const line of lines) {
                    const linet = line.trim();
                    if (linet === '') continue;
                    const [name, itypeStr] = linet.split(/\s+/);
                    const itype = Types.stringToNetwork(itypeStr);
                    result.get(itype).push(name);
                }
                result.forEach(function(val, key, map) {
                    map[key] = val.sort();
                });
                interfaces = result;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const stderr = this.text.trim();
                if (stderr) {
                    throw new Error(`Failed running listInterfacesProc. Error: ${stderr}`);
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                throw new Error(`Failed running listInterfacesProc. Exit code: ${exitCode}, exit status: ${exitStatus}`);
            }

            autoSelectInterface();
            if (networkType === Types.Network.Wireless) {
                wirelessInfoProc.running = true;
            } else if (networkType === Types.Network.Wired){
                linkSpeedView.reload();
                linkSpeed = parseInt(linkSpeedView.text().trim()) || 0;
            }
            lanIPProc.running = true;
        }
    }

    Process {
        id: lanIPProc
        command: ["ip", "-details", "-json", "address", "show", root.activeInterface]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    if (data && data.length > 0) {
                        lanIPs = data[0].addr_info ? data[0].addr_info.map(info => info.local).filter(ip => ip) : [];
                    }
                } catch (e) {
                    console.error("Network Service: Failed to parse ip JSON:", e);
                    lanIPs = [];
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const stderr = this.text.trim();
                if (stderr) {
                    throw new Error(`Failed running lanIPProc. Error: ${stderr}`);
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                throw new Error(`Failed running lanIPProc. Exit code: ${exitCode}, exit status: ${exitStatus}`);
            }
        }
    }

    Process {
        id: wirelessInfoProc
        command: ["iw", "dev", root.activeInterface, "link"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split('\n');
                let ssidFound = "", freqFound = "", rxBitFound = "", txBitFound = "", signalFound = "";
                for (let line of lines) {
                    if (line.includes("SSID:")) ssidFound = line.split("SSID:")[1].trim();
                    if (line.includes("freq:")) freqFound = line.split("freq:")[1].trim();
                    if (line.includes("signal:")) signalFound = line.split("signal:")[1].trim().split(' ')[0];
                    if (line.includes("rx bitrate:")) rxBitFound = line.split("rx bitrate:")[1].trim();
                    if (line.includes("tx bitrate:")) txBitFound = line.split("tx bitrate:")[1].trim();
                }
                ssid = ssidFound;
                frequency = freqFound ? parseInt(freqFound) : 0;
                signalStrength = signalFound ? parseInt(signalFound) : 0;
                bitrateRx = rxBitFound ? parseFloat(rxBitFound) : 0;
                bitrateTx = txBitFound ? parseFloat(txBitFound) : 0;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const stderr = this.text.trim();
                if (stderr) {
                    throw new Error(`Failed running wirelessInfoProc. Error: ${stderr}`);
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                throw new Error(`Failed running wirelessInfoProc. Exit code: ${exitCode}, exit status: ${exitStatus}`);
            }
        }
    }

    Process {
        id: wanIPProc
        // TODO: Use additional sources to improve robustness.
        command: ["dig", "+short", "@resolver2.opendns.com", "myip.opendns.com"]
        stdout: StdioCollector {
            onStreamFinished: wanIP = this.text.trim() || "N/A"
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const stderr = this.text.trim();
                if (stderr) {
                    throw new Error(`Failed running wanIPProc. Error: ${stderr}`);
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                throw new Error(`Failed running wanIPProc. Exit code: ${exitCode}, exit status: ${exitStatus}`);
            }
        }
    }

    // Public API
    function setActiveInterface(interfaceName, networkType) {
        root.activeInterface = interfaceName;
        root.networkType = networkType;
        resetState();
        updateInfo();

        // Persist the selection
        BarState.data.network.activeInterface = interfaceName;
        BarState.data.network.type = networkType;
    }

    // Internal: Auto-select the most appropriate interface, if none is already
    // selected. Priority order: persisted state, wireless, wired, loopback.
    function autoSelectInterface() {
        if (activeInterface) return;

        // Wait for the state file to be loaded
        BarState.view.waitForJob();

        // Try persisted state first
        const state = BarState.data.network;
        if (state.activeInterface && interfaces.get(state.type)?.includes(state.activeInterface)) {
            activeInterface = state.activeInterface;
            networkType = state.type;
            return;
        }

        let wireless = interfaces.get(Types.Network.Wireless),
            wired = interfaces.get(Types.Network.Wired),
            iface, ifaceType;

        if (wireless?.length) {
            iface = wireless[0];
            ifaceType = Types.Network.Wireless;
        } else if (wired?.length) {
            iface = wired[0];
            ifaceType = Types.Network.Wired;
        } else {
            iface = 'lo';
            ifaceType = Types.Network.Virtual;
        }

        if (iface) {
            activeInterface = iface
            networkType = ifaceType
        }

        // Persist the selection
        state.activeInterface = iface;
        state.type = ifaceType;
    }

    function updateRates() {
        if (!activeInterface) return;
        let prevTx = tx, prevRx = rx;
        rxBytesView.reload();
        rx = parseInt(rxBytesView.text().trim()) || 0;
        txBytesView.reload();
        tx = parseInt(txBytesView.text().trim()) || 0;
        if (prevTx > 0 && prevRx > 0) {  // Skip initial
            rateUp = Math.max(0, tx - prevTx);    // Up = tx (bytes/s)
            rateDown = Math.max(0, rx - prevRx);  // Down = rx
        }
    }

    function updateInfo() {
        listInterfacesProc.running = true;
    }

    function updateExternal() {
        wanIPProc.running = true;
    }

    function resetState() {
        tx = 0; rx = 0; rateUp = 0; rateDown = 0;
        lanIPs = []; ssid = ""; frequency = 0; signalStrength = 0;
        bitrateTx = 0; bitrateRx = 0; linkSpeed = 0;
    }
}
