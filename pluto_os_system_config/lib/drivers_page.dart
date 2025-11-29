import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Driver {
  final String name;
  final String? description;

  Driver({
    required this.name,
    required this.description,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      name: json['module'],
      description: null
    );
  }
}

class Firmware {
  final String name;
  final String package;

  Firmware({
    required this.name,
    required this.package,
  });

  factory Firmware.fromJson(Map<String, dynamic> json) {
    return Firmware(
      name: json['name'],
      package: json['package']
    );
  }
}

class DriversPage extends StatefulWidget {
  const DriversPage({ super.key });

  @override State<StatefulWidget> createState() {
    return DriversPageState();
  }
}

class DriversPageState extends State<DriversPage> {
  List<Driver> loadedDrivers = [];
  List<Firmware> firmwareBundles = [];

  @override
  void initState() {
    super.initState();

    getLoadedDrivers();
    getFirmwareBundles();
  }

  Future<void> getLoadedDrivers() async {
    final commandResult = await Process.run("bash", [
      "-c",
      "lsmod | jc --lsmod",
    ]);

    if (commandResult.exitCode != 0) return;

    setState(() {
      final List<dynamic> jsonList = json.decode(commandResult.stdout);

      loadedDrivers = jsonList.map((json) => Driver.fromJson(json)).toList();
    });
  }

  Future<void> getFirmwareBundles() async {
    try {
      final File jsonFile = File('/pluto/firmware.json');

      if (!await jsonFile.exists()) return;

      final String jsonString = await jsonFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      setState(() {
        firmwareBundles = jsonList
            .map((json) => Firmware.fromJson(json))
            .toList();
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Text(
            "Loaded Drivers",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Text("Drivers are packages of code that can be dynamically loaded in and out of memory to support various hardware devices"),
          ...loadedDrivers.map((device) => ListTile(
            title: Text(device.name),
            // subtitle: Text(device.description ?? "..."),
          )),

          const Text(
            "Firmware Bundles",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Text("Firmware bundles are proprietary binary blobs included in PlutoOS to enable the use of certain devices that require them. This is necessary because some hardware manufacturers do not release source code necessary to build the firmware itself."),
          ...firmwareBundles.map((device) => ListTile(
            title: Text(device.name),
            subtitle: Text(device.package),
          )),
        ],
      ),
    );

  }

}