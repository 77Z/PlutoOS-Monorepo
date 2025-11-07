const pkgDir = Deno.readDirSync("./targetroot/var/cache/pacman/pkg/");

console.log("[SUB-TASK] Indexing firmware...");

interface FirmwareEntry {
    name: string;
    package: string;
}

const firmware: FirmwareEntry[] = [];

const firmwareDescMap = new Map<string, string>([
    ["amdgpu", "AMD Radeon GPU"],
    ["atheros", "Qualcomm Atheros WiFi and Bluetooth Adapters"],
    ["broadcom", "Broadcom and Cypress network adapters"],
    ["cirrus", "Cirrus Logic audio devices"],
    ["intel", "Intel"],
    ["liquidio", "Cavium LiquidIO server adapters"],
    ["marvell", "Marvell devices"],
    ["mediatek", "MediaTek and Ralink devices"],
    ["mellanox", "Mellanox Spectrum switches"],
    ["nfp", "Netronome Flow Processors"],
    ["nvidia", "nVidia GPUs and SoCs"],
    ["other", "Unsorted firmware for various devices"],
    ["qcom", "Qualcomm SoCs"],
    ["qlogic", "QLogic devices"],
    ["radeon", "ATI Radeon GPUs"],
    ["realtek", "Realtek devices"],
]);

for (const pkg of pkgDir) {
    if (!pkg.isFile) continue;

    if (!pkg.name.startsWith("linux-firmware")) continue;

    if (pkg.name.endsWith(".sig")) continue;

    if (pkg.name.startsWith("linux-firmware-2")) continue;

    const firmwareName = pkg.name.split("-")[2];

    const desc = firmwareDescMap.get(firmwareName) || "Various firmware";

    firmware.push({
        name: desc,
        package: `pluto-firmware-${firmwareName}`,
    });
}

// ucode will always be there
firmware.push({
    name: "Intel CPU Microcode",
    package: "pluto-intel-ucode",
});

firmware.push({
    name: "AMD CPU Microcode",
    package: "pluto-amd-ucode",
});

Deno.writeTextFileSync("./firmware.json", JSON.stringify(firmware));