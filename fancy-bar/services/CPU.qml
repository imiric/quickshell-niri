pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    // Array of CPU core usage percentages (0.0 to 1.0), one per core
    property var coreUsages: []

    // Overall CPU usage percentage (0.0 to 1.0), average across all cores
    property real overallUsage: 0.0

    // Previous /proc/stat values for delta calculations
    property var prevStats: []

    // Top processes, array of {pid: int, comm: string, cpu: float}
    property var topProcesses: []

    // Load average values (1-min, 5-min, 15-min)
    property var loadAvg: []

    // Number of top processes to show
    property int numTopProcesses: Config.data.cpu.numTopProcesses || 5

    Process {
        id: psProc
        command: ["sh", "-c", `ps -eo pid,comm,%cpu --sort=-%cpu --no-headers | head -${numTopProcesses+10}`]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split('\n').filter(l => l.trim() !== '');
                let tp = [];
                for (let line of lines) {
                    if (tp.length == numTopProcesses) break;
                    let parts = line.trim().split(/\s+/);
                    if (parts.length === 3) {
                        let comm = parts[1];
                        if (comm === 'ps') continue;  // Skip ps itself
                        let pid = parseInt(parts[0]);
                        let cpu = parseFloat(parts[2]);
                        tp.push({pid: pid, comm: comm, cpu: cpu});
                    }
                }
                topProcesses = tp;
            }
        }
    }

    Process {
        id: loadAvgProc
        command: ["uptime"]
        stdout: StdioCollector {
            onStreamFinished: {
                let line = this.text.trim();
                let parts = line.split("load average:");
                if (parts.length > 1) {
                    let loads = parts[1].trim().split(',').map(s => parseFloat(s.trim()));
                    if (loads.length >= 3) {
                        loadAvg = loads;
                    }
                }
            }
        }
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        onLoadFailed: function(error) {
            console.log("CPU Service: FileView load failed for /proc/stat:", error);
        }
    }

    Timer {
        interval: Config.data.cpu.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updateCpuUsage()
            psProc.running = true
            loadAvgProc.running = true
        }
    }

    function updateCpuUsage() {
        statFile.reload();
        let content = statFile.text();

        if (content === "") {
            return;
        }

        let lines = content.split('\n');
        let currentStats = [];

        // Parse lines starting with "cpu" (cpu, cpu0, cpu1, ...)
        for (let i = 0; i < lines.length; ++i) {
            let line = lines[i].trim();
            if (line.startsWith('cpu')) {
                let parts = line.split(/\s+/);
                if (parts.length >= 8) {
                    let user = parseInt(parts[1]);
                    let nice = parseInt(parts[2]);
                    let system = parseInt(parts[3]);
                    let idle = parseInt(parts[4]);
                    let iowait = parseInt(parts[5]);
                    let irq = parseInt(parts[6]);
                    let softirq = parseInt(parts[7]);
                    // Total ticks: sum of all except idle for denominator
                    let total = user + nice + system + idle + iowait + irq + softirq;
                    currentStats.push({ total: total, idle: idle });
                }
            }
        }

        if (prevStats.length === currentStats.length && prevStats.length > 0) {
            let totalUsage = 0.0;
            let coreUsagesTemp = [];

            // Calculate for each core (skip overall "cpu")
            for (let j = 1; j < currentStats.length; ++j) {
                let current = currentStats[j];
                let prev = prevStats[j];
                let deltaTotal = current.total - prev.total;
                let deltaIdle = current.idle - prev.idle;
                let usage = (deltaTotal > 0) ? (deltaTotal - deltaIdle) / deltaTotal : 0.0;
                usage = Math.min(Math.max(usage, 0.0), 1.0);
                coreUsagesTemp.push(usage);
            }

            // Overall usage
            let overallCurrent = currentStats[0];
            let overallPrev = prevStats[0];
            let overallDeltaTotal = overallCurrent.total - overallPrev.total;
            let overallDeltaIdle = overallCurrent.idle - overallPrev.idle;
            totalUsage = (overallDeltaTotal > 0) ? (overallDeltaTotal - overallDeltaIdle) / overallDeltaTotal : 0.0;
            totalUsage = Math.min(Math.max(totalUsage, 0.0), 1.0);

            coreUsages = coreUsagesTemp;
            overallUsage = totalUsage;
        } else if (prevStats.length === 0) {
            // First run: Store baselines
            prevStats = currentStats;
        }

        prevStats = currentStats;
    }
}
