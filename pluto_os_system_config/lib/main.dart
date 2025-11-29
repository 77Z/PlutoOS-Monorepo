import 'package:flutter/material.dart';
import 'package:pluto_os_system_config/devices_page.dart';
import 'package:pluto_os_system_config/drivers_page.dart';
import 'package:pluto_os_system_config/linux_environment_page.dart';
import 'package:pluto_os_system_config/system_updates_page.dart';
import 'package:yaru/yaru.dart';
import './data/apis/framework_api.dart';

/* class FirmwareBundle {
  final String name;
  final String package;
  final String description;

  FirmwareBundle({
    required this.name,
    required this.package,
    required this.description,
  });

  factory FirmwareBundle.fromJson(Map<String, dynamic> json) {
    return FirmwareBundle(
      name: json['name'] as String,
      package: json['package'] as String,
      description: json['description'] as String,
    );
  }
} */

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: yaru.theme,
          // darkTheme: yaru.darkTheme,
          darkTheme: MyTheme().darkTheme,
          home: _Home(),
          title: "PlutoOS System Configuration",
        );
      },
    );
  }
}

class MyTheme extends YaruThemeData {
  @override
  ThemeData get darkTheme {
    return super.darkTheme?.copyWith(
          textTheme: super.darkTheme?.textTheme.apply(
            fontFamily: 'Inter',
            // bodyColor: Color(0xAAFF0000)
          ),
        ) ??
        ThemeData.dark();
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaruWindowTitleBar(),
      body: YaruMasterDetailPage(
        length: 7,
        tileBuilder: (context, index, selected, availableWidth) {
          if (index == 0) {
            return const YaruMasterTile(
              title: Text('System Updates'),
              leading: Icon(YaruIcons.update_available_filled),
            );
          } else if (index == 1) {
            return const YaruMasterTile(
              title: Text('Linux Environment'),
              leading: Icon(YaruIcons.ubuntu_logo_simple),
            );
          } else if (index == 2) {
            return const YaruMasterTile(
              title: Text("Drivers & Firmware"),
              leading: Icon(YaruIcons.drive_optical_filled),
            );
          } else if (index == 3) {
            return const YaruMasterTile(
              title: Text("Devices"),
              leading: Icon(YaruIcons.computer_filled),
            );
          } else if (index == 4) {
            return const YaruMasterTile(
              title: Text("Framework Exclusive"),
              leading: Icon(YaruIcons.computer_legacy),
            );
          } else if (index == 5) {
            return const YaruMasterTile(
              title: Text("System Storage"),
              leading: Icon(YaruIcons.drive_harddisk_broken),
            );
          } else if (index == 6) {
            return const YaruMasterTile(
              title: Text("Backup"),
              leading: Icon(YaruIcons.drive_harddisk_filled),
            );
          }

          throw Exception("Index misalligned?");
        },
        pageBuilder: (context, index) {
          if (index == 0) {
            return SystemUpdatesPage();
          } else if (index == 1) {
            return LinuxEnvironmentPage();
          } else if (index == 2) {
            return DriversPage();
          } else if (index == 3) {
            return DevicesPage();
          } else if (index == 4) {
            // framework module should let you control ambient light sensor, leds, etc.
            return Center(child: 
              FrameworkApi.isFrameworkLaptop() ? const Text("You are running on framework!") : const Text("Not a framework :("),);
          } else if (index == 5) {
            return Center(child: const Text("PlutoOS makeup, user files, and swap"),);
          } else if (index == 6) {
            return Center(child: const Text("backup user data"),);
          }

          return Center(child: Text("Failed to load page"));
        },
      ),
    );
  }
}

/* class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<FirmwareBundle> firmwareBundles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFirmwareBundles();
  }

  Future<void> loadFirmwareBundles() async {
    try {
      final File jsonFile = File(
        '/code/PlutoDevelopment/pluto_os_system_config/data/firmware_bundles.json',
      );

      if (!await jsonFile.exists()) {
        return;
      }

      final String jsonString = await jsonFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      setState(() {
        firmwareBundles = jsonList
            .map((json) => FirmwareBundle.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "PlutoOS Firmware Bundles",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  loadFirmwareBundles();
                },
                tooltip: 'Refresh firmware bundles',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: firmwareBundles.length,
                itemBuilder: (context, index) {
                  final bundle = firmwareBundles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: 300,
                      child: Card.filled(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bundle.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bundle.package,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bundle.description,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} */