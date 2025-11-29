import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pluto_os_system_config/lspci_output.dart';
import 'package:pluto_os_system_config/lsusb_output.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<StatefulWidget> createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage> {
  String bruh = "BRUH";
  List<UsbDevice> usbDevices = [];
  List<PciDevice> pciDevices = [];

  @override
  void initState() {
    super.initState();

    getUSBDevices();
    getPCIDevices();
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                pciDevices.clear();
                usbDevices.clear();

                getPCIDevices();
                getUSBDevices();
              });
            },
            tooltip: 'Reload connected devices',
          ),
          Text(
            "USB Bus",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(bruh),
          ...usbDevices
              .map(
                (device) => ListTile(
                  title: Text(device.description ?? 'Unknown Device'),
                  subtitle: Text('${device.id} - ${device.bus}'),
                ),
              )
              .toList(),
          Text(
            "PCI Bus",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          ...pciDevices.map(
            (device) => ListTile(
              title: Text("${device.vendor} ${device.device}"),
              subtitle: Text("Pluto Driver: ${device.driver}"),
            ),
          ),
        ],
      ),
    );
  }
}
