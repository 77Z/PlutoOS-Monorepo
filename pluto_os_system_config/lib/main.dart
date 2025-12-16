import 'package:flutter/material.dart';
import 'package:pluto_os_system_config/about_page.dart';
import 'package:pluto_os_system_config/devices_page.dart';
import 'package:pluto_os_system_config/drivers_page.dart';
import 'package:pluto_os_system_config/linux_environment_page.dart';
import 'package:pluto_os_system_config/power_page.dart';
import 'package:pluto_os_system_config/system_updates_page.dart';
import 'package:plutoos_system_library/plutoos_system_library.dart';
import 'package:yaru/yaru.dart';

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
        length: 9,
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
          } else if (index == 7) {
            return const YaruMasterTile(
              title: Text("Power & Battery"),
              leading: Icon(YaruIcons.battery),
            );
          } else if (index == 8) {
            return Column(
              children: [
                SizedBox(height: 50, width: 1,),
                const YaruMasterTile(
                  title: Text("About System"),
                  leading: Icon(YaruIcons.information),
                )
              ],
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
              PlutoosSystemLibrary.isFrameworkLaptop() ? const Text("You are running on framework!") : const Text("Not a framework :("),);
          } else if (index == 5) {
            // return Center(child: const Text("PlutoOS makeup, user files, and swap"),);
            return Center(child: const Text("Page WIP..."),);
          } else if (index == 6) {
            return Center(child: const Text("Page WIP..."),);
          } else if (index == 7) {
            // return Center(child: const Text("show battery wattage, and breakdown of what's drawing power"));

            return PowerPage();
          } else if (index == 8) {
            return AboutPage();
          }

          return Center(child: Text("Failed to load page"));
        },
      ),
    );
  }
}