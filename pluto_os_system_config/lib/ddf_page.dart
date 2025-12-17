import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pluto_os_system_config/lspci_output.dart';
import 'package:pluto_os_system_config/lsusb_output.dart';
import 'package:yaru/icons.dart';
import 'package:yaru/yaru.dart';
import 'fwupd-interface.dart';
import 'package:dbus/dbus.dart';


/* ----------- Drivers Page ----------- */
class DDFDriversPage extends StatefulWidget {
  const DDFDriversPage({ super.key });

  @override
  State<StatefulWidget> createState() => DDFDriversPageState();
}

class BasicDriverData {
  final String name;
  final String? description;

  BasicDriverData({
    required this.name,
    required this.description,
  });

  factory BasicDriverData.fromJson(Map<String, dynamic> json) {
    return BasicDriverData(
      name: json['module'],
      description: null
    );
  }
}

class DDFDriversPageState extends State<DDFDriversPage> {
  List<BasicDriverData> loadedDrivers = [];

  @override
  void initState() {
    super.initState();

    getLoadedDrivers();
  }

  Future<void> getLoadedDrivers() async {
    final commandResult = await Process.run("bash", [
      "-c",
      "lsmod | jc --lsmod",
    ]);

    if (commandResult.exitCode != 0) return;

    setState(() {
      final List<dynamic> jsonList = json.decode(commandResult.stdout);
      loadedDrivers = jsonList.map((json) => BasicDriverData.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          spacing: 20,
          children: [
            /* Header bar */
            Row(
              spacing: 15,
              children: [
                YaruBackButton(onPressed: () => Navigator.pop(context)),
                const Text("System Drivers", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
              ],
            ),
        
            /* Page Content */
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: loadedDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = loadedDrivers[index];

                      return YaruExpandable(
                        header: Text(driver.name.trim()),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: Process.run("modinfo", [driver.name]).then((result) => 
                                    result.exitCode == 0 ? result.stdout.toString() : "No information available"
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    }
                                    return Text(snapshot.data ?? "No information available", style: TextStyle(fontFamily: "UbuntuMono"),);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ]
        )
      )
    );
  }
}


/* ----------- PCI Dev Page ----------- */
class PCIDevicesPage extends StatefulWidget {
  const PCIDevicesPage({ super.key });

  @override
  State<StatefulWidget> createState() => PCIDevicesPageState();
}

class PCIDevicesPageState extends State<PCIDevicesPage> {
  List<PciDevice> pciDevices = [];

  @override
  void initState() {
    super.initState();

    getPCIDevices();
  }

  Future<void> getPCIDevices() async {
    final commandResult = await Process.run("bash", [
      "-c",
      "lspci -mmvk | jc --lspci",
    ]);

    if (commandResult.exitCode != 0) return;

    setState(() {
      final List<dynamic> jsonList = json.decode(commandResult.stdout);
      pciDevices = jsonList.map((json) => PciDevice.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          spacing: 20,
          children: [
            /* Header bar */
            Row(
              spacing: 15,
              children: [
                YaruBackButton(onPressed: () => Navigator.pop(context)),
                const Text("PCI Devices", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
              ],
            ),
        
            /* Page Content */
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pciDevices.length,
                    itemBuilder: (context, index) {
                      final device = pciDevices[index];

                      return YaruExpandable(
                        header: Text("${device.vendor} ${device.device}".trim()),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Slot: ${device.slot}"),
                                Text("Domain: ${device.domain}"),
                                Text("Bus: ${device.bus}"),
                                Text("Dev: ${device.dev}"),
                                Text("Function: ${device.function}"),
                                Text("Class: ${device.klass}"),
                                Text("Vendor: ${device.vendor}"),
                                Text("Device Name: ${device.device}"),
                                Text("Subsystem Vendor: ${device.svendor}"),
                                Text("Subsystem Device: ${device.sdevice}"),
                                Text("progif: ${device.progif}"),
                                Text("System Driver: ${device.driver}"),
                                Text("Module: ${device.module}"),
                                Text("IOMMU Group: ${device.iommugroup}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ]
        )
      )
    );
  }
}

/* ----------- USB Dev Page ----------- */
class USBDevicesPage extends StatefulWidget {
  const USBDevicesPage({ super.key });

  @override
  State<StatefulWidget> createState() => USBDevicesPageState();
}

class USBDevicesPageState extends State<USBDevicesPage> {
  List<UsbDevice> usbDevices = [];

  @override
  void initState() {
    super.initState();

    getUSBDevices();
  }

  Future<void> getUSBDevices() async {
    final commandResult = await Process.run("bash", [
      "-c",
      "lsusb -v | jc --lsusb",
    ]);

    if (commandResult.exitCode != 0) return;

    setState(() {
      final List<dynamic> jsonList = json.decode(commandResult.stdout);
      usbDevices = jsonList.map((json) => UsbDevice.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          spacing: 20,
          children: [
            /* Header bar */
            Row(
              spacing: 15,
              children: [
                YaruBackButton(onPressed: () => Navigator.pop(context)),
                const Text("USB Devices", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
              ],
            ),
        
            /* Page Content */
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: usbDevices.length,
                    itemBuilder: (context, index) {
                      final device = usbDevices[index];

                      return YaruExpandable(
                        header: Text(device.description.trim()),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("bus: ${device.bus}"),
                                Text("device: ${device.device}"),
                                Text("id: ${device.id}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ]
        )
      )
    );
  }
}


/* ----------- Firmware Page ----------- */
class FirmwarePage extends StatefulWidget {
  const FirmwarePage({ super.key });

  @override
  State<StatefulWidget> createState() => FirmwarePageState();
}

class FirmwareBundle {
  final String name;
  final String package;

  FirmwareBundle({
    required this.name,
    required this.package,
  });

  factory FirmwareBundle.fromJson(Map<String, dynamic> json) {
    return FirmwareBundle(
      name: json['name'],
      package: json['package']
    );
  }
}

class FirmwarePageState extends State<FirmwarePage> {
  var systemClient = DBusClient.system();

  List<Map<String, DBusValue>> devices = [];
  List<FirmwareBundle> firmwareBundles = [];

  @override
  void initState() {
    super.initState();

    getFirmwareCompatDevices();
    getFirmwareBundles();
  }

  void getFirmwareCompatDevices() async {
    var object = OrgFreedesktopFwupd(systemClient, 'org.freedesktop.fwupd');

    var data = await object.callGetDevices();
    setState(() => devices = data);
  }

  Future<void> getFirmwareBundles() async {
    try {
      final jsonFile = File("/pluto/firmware.json");

      if (!await jsonFile.exists()) return;

      final List<dynamic> jsonList = json.decode(await jsonFile.readAsString());

      setState(() {
        firmwareBundles = jsonList.map((json) => FirmwareBundle.fromJson(json)).toList();
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          spacing: 20,
          children: [
            /* Header bar */
            Row(
              spacing: 15,
              children: [
                YaruBackButton(onPressed: () => Navigator.pop(context)),
                const Text("Firmware", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
              ],
            ),
        
            /* Page Content */
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  // ElevatedButton(onPressed: () => getFirmwareCompatDevices(), child: const Text("reload firmware devices")),
                  const Text("Devices w/ Firmware", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final name = device['Name']?.toNative()?.toString() ?? 'Unknown Device';
                      final vendor = device['Vendor']?.toNative()?.toString() ?? '';

                      return YaruExpandable(
                        header: Text("$vendor $name".trim()),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Version: ${device['Version']?.toNative() ?? 'N/A'}', textAlign: TextAlign.start,),
                                Text('GUID: ${device['Guid']?.toNative() ?? 'N/A'}'),
                                Text('Plugin: ${device['Plugin']?.toNative() ?? 'N/A'}'),
                                Text('Flags: ${device['Flags']?.toNative() ?? 'N/A'}'),
                                Text('Created: ${device['Created']?.toNative() ?? 'N/A'}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 50, width: 50),
                  const Text("Installed Firmware Bundles", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text("Firmware bundles are proprietary binary blobs included in PlutoOS to enable the use of certain devices that require them. This is necessary because some hardware manufacturers do not release source code necessary to build the firmware itself."),
                  ...firmwareBundles.map((device) => ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.package),
                  )),
                ],
              ),
            )
          ]
        )
      )
    );
  }
}


class DdfPage extends StatefulWidget {
  const DdfPage({ super.key });

  @override
  State<StatefulWidget> createState() => DDFPageState();
}

class DDFPageState extends State<DdfPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: ListView(
        children: [
          Text("Devices, Drivers, & Firmware", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40), textAlign: TextAlign.center),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FirmwarePage())),
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Row(
                  children: [
                    Text("Firmware"),
                    Spacer(),
                    Icon(YaruIcons.arrow_right)
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DDFDriversPage())),
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Row(
                  children: [
                    Text("Drivers"),
                    Spacer(),
                    Icon(YaruIcons.arrow_right)
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PCIDevicesPage())),
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Row(
                  children: [
                    Text("PCI Devices"),
                    Spacer(),
                    Icon(YaruIcons.arrow_right)
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => USBDevicesPage())),
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Row(
                  children: [
                    Text("USB Devices"),
                    Spacer(),
                    Icon(YaruIcons.arrow_right)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}