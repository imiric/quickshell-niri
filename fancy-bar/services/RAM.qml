pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    // RAM metrics in kibibytes
    property real total: 0.0
    property real used: 0.0
    property real shared: 0.0
    property real buffers: 0.0
    property real cached: 0.0
    property real sreclaimable: 0.0
    property real free: 0.0
    property real available: 0.0

    // Top processes, array of {pid: int, comm: string, mem: float}
    property var topProcesses: []

    signal statsUpdated()

    Process {
        id: psProc
        command: ["sh", "-c", `ps -eo pid,comm,%mem --sort=-%mem --no-headers | head -${Config.data.ram.numTopProcesses+10}`]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split('\n').filter(l => l.trim() !== '');
                let tp = [];
                for (let line of lines) {
                    if (tp.length == Config.data.ram.numTopProcesses) break;
                    let parts = line.trim().split(/\s+/);
                    if (parts.length === 3) {
                        let comm = parts[1];
                        if (comm === 'ps') continue;  // Skip ps itself
                        let pid = parseInt(parts[0]);
                        let mem = parseFloat(parts[2]);
                        tp.push({pid: pid, comm: comm, mem: mem});
                    }
                }
                topProcesses = tp;
            }
        }
    }

    FileView {
        id: meminfoFile
        path: "/proc/meminfo"
        onLoadFailed: function(error) {
            console.log("RAM Service: FileView load failed for /proc/meminfo:", error);
        }
    }

    Timer {
        interval: Config.data.ram.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updateRamStats()
            psProc.running = true
        }
    }

    function updateRamStats() {
        meminfoFile.reload();
        let content = meminfoFile.text();

        if (content === "") return;

        let lines = content.split('\n');
        let stats = {};

        // Parse key lines
        for (let line of lines) {
            let parts = line.split(/\s+/);
            if (parts.length >= 2) {
                let key = parts[0].slice(0, -1);  // Remove colon
                let value = parseFloat(parts[1]);
                stats[key] = value;
            }
        }

        total = stats.MemTotal || 0.0;
        free = stats.MemFree || 0.0;
        buffers = stats.Buffers || 0.0;
        cached = stats.Cached || 0.0;
        shared = stats.Shmem || 0.0;
        available = stats.MemAvailable || (free + buffers + cached);
        sreclaimable = stats.SReclaimable || 0.0;
        used = Math.max(0, total - available);

        statsUpdated()
    }
}
