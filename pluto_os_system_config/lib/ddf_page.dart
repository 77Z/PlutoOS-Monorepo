import 'package:flutter/material.dart';
import 'package:yaru/icons.dart';
import 'package:yaru/yaru.dart';
import 'fwupd-interface.dart';
import 'package:dbus/dbus.dart';


/*  */


/* ----------- Firmware Page ----------- */
class FirmwarePage extends StatefulWidget {
  const FirmwarePage({ super.key });

  @override
  State<StatefulWidget> createState() => FirmwarePageState();
}

class FirmwarePageState extends State<FirmwarePage> {
  var systemClient = DBusClient.system();

  List<Map<String, DBusValue>> devices = [];

  @override
  void initState() {
    super.initState();

    getFirmwareCompatDevices();
  }

  void getFirmwareCompatDevices() async {
    var object = OrgFreedesktopFwupd(systemClient, 'org.freedesktop.fwupd');

    var data = await object.callGetDevices();
    setState(() => devices = data);
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
                  const Text("Installed Firmware Bundles", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FirmwarePage())),
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FirmwarePage())),
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FirmwarePage())),
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