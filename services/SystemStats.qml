pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// CPU, RAM, GPU and temperatures. Only runs while a widget that shows them is
// on screen (widgets register with `watchers`), every "stats.interval" ms.
//
// GPU: AMD reports a real busy %, NVIDIA via nvidia-smi, Intel only exposes
// its clock speed without root, so for Intel we show clock as a % of max.
Singleton {
    id: root

    property int watchers: 0

    property real cpu: 0            // 0..1
    property real cpuFreq: 0        // MHz (average)
    property real cpuTemp: -1       // °C, -1 = unknown
    property int cores: 0
    property real memUsed: 0        // GiB
    property real memTotal: 0
    property real swapUsed: 0
    property real swapTotal: 0
    readonly property real mem: memTotal > 0 ? memUsed / memTotal : 0

    property string gpuName: ""
    property real gpu: -1           // 0..1, -1 = unknown
    property bool gpuIsClock: false // true = "gpu" is clock speed / max (Intel)
    property real gpuFreq: 0
    property real gpuMaxFreq: 0
    property real gpuTemp: -1
    property real vramUsed: -1      // GiB
    property real vramTotal: -1

    // Last 40 readings for the little graphs.
    property var cpuHistory: []
    property var memHistory: []
    property var gpuHistory: []

    property var lastCpu: null

    function push(list, v) {
        const l = list.slice(-39);
        l.push(v);
        return l;
    }

    readonly property string script: "
head -n1 /proc/stat
grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):' /proc/meminfo
echo \"cores $(nproc 2>/dev/null)\"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | awk '{s+=$1;n++} END{if(n) print \"cpufreq\", s/n/1000}'
for h in /sys/class/hwmon/hwmon*; do n=$(cat $h/name 2>/dev/null); t=$(cat $h/temp1_input 2>/dev/null); [ -z \"$t\" ] && continue
  case $n in coretemp|k10temp|zenpower|cpu_thermal|x86_pkg_temp) echo \"cputemp $t\";; amdgpu|nouveau|radeon) echo \"gputemp $t\";; esac; done
for c in /sys/class/drm/card[0-9]; do d=$c/device; [ -f $d/vendor ] || continue; echo \"gpuvendor $(cat $d/vendor)\"
  [ -f $d/gpu_busy_percent ] && echo \"gpubusy $(cat $d/gpu_busy_percent)\"
  [ -f $d/mem_info_vram_used ] && echo \"vram $(cat $d/mem_info_vram_used) $(cat $d/mem_info_vram_total)\"
  [ -f $c/gt_cur_freq_mhz ] && echo \"gpufreq $(cat $c/gt_cur_freq_mhz) $(cat $c/gt_max_freq_mhz)\"
  [ -f $d/tile0/gt0/freq0/act_freq ] && echo \"gpufreq $(cat $d/tile0/gt0/freq0/act_freq) $(cat $d/tile0/gt0/freq0/max_freq)\"
done
command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | sed 's/^/nvidia /'
"

    Process {
        id: reader
        command: ["sh", "-c", root.script]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    function parse(text) {
        let memTotalK = 0, memAvailK = 0, swapTotalK = 0, swapFreeK = 0;
        let cpuTemps = [], gotGpu = false, vendor = "";
        let g = -1, gClock = false, gf = 0, gmax = 0, gt = -1, vu = -1, vt = -1;
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const f = lines[i].trim().split(/[\s,]+/);
            switch (f[0]) {
            case "cpu":
                {
                    const n = f.slice(1).map(Number);
                    const idle = n[3] + (n[4] || 0), total = n.reduce((a, b) => a + b, 0);
                    if (lastCpu && total > lastCpu.total)
                        cpu = Math.max(0, Math.min(1, 1 - (idle - lastCpu.idle) / (total - lastCpu.total)));
                    lastCpu = { idle: idle, total: total };
                    break;
                }
            case "MemTotal:":
                memTotalK = Number(f[1]);
                break;
            case "MemAvailable:":
                memAvailK = Number(f[1]);
                break;
            case "SwapTotal:":
                swapTotalK = Number(f[1]);
                break;
            case "SwapFree:":
                swapFreeK = Number(f[1]);
                break;
            case "cores":
                cores = Number(f[1]) || 0;
                break;
            case "cpufreq":
                cpuFreq = Number(f[1]) || 0;
                break;
            case "cputemp":
                cpuTemps.push(Number(f[1]) / 1000);
                break;
            case "gputemp":
                gt = Number(f[1]) / 1000;
                break;
            case "gpuvendor":
                vendor = f[1];
                break;
            case "gpubusy":
                g = Number(f[1]) / 100;
                gotGpu = true;
                break;
            case "vram":
                vu = Number(f[1]) / 1073741824;
                vt = Number(f[2]) / 1073741824;
                break;
            case "gpufreq":
                gf = Number(f[1]);
                gmax = Number(f[2]);
                if (!gotGpu && gmax > 0) {
                    g = gf / gmax;
                    gClock = true;
                }
                break;
            case "nvidia":
                g = Number(f[1]) / 100;
                vu = Number(f[2]) / 1024;
                vt = Number(f[3]) / 1024;
                gt = Number(f[4]);
                gClock = false;
                vendor = "0x10de";
                break;
            }
        }
        memTotal = memTotalK / 1048576;
        memUsed = (memTotalK - memAvailK) / 1048576;
        swapTotal = swapTotalK / 1048576;
        swapUsed = (swapTotalK - swapFreeK) / 1048576;
        cpuTemp = cpuTemps.length ? Math.max.apply(null, cpuTemps) : -1;
        gpu = g;
        gpuIsClock = gClock;
        gpuFreq = gf;
        gpuMaxFreq = gmax;
        gpuTemp = gt;
        vramUsed = vu;
        vramTotal = vt;
        gpuName = vendor === "0x8086" ? "Intel GPU" : vendor === "0x1002" ? "AMD GPU" : vendor === "0x10de" ? "NVIDIA GPU" : (vendor ? "GPU" : "");

        cpuHistory = push(cpuHistory, cpu);
        memHistory = push(memHistory, mem);
        gpuHistory = push(gpuHistory, Math.max(0, gpu));
    }

    Timer {
        interval: Config.statsInterval
        repeat: true
        triggeredOnStart: true
        running: root.watchers > 0
        onTriggered: if (!reader.running) reader.running = true
    }
}
