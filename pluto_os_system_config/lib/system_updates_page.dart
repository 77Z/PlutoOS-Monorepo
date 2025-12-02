import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import 'package:plutoos_system_library/models/latest_version_info.dart';
import 'package:plutoos_system_library/plutoos_system_library.dart';

class ActivelyUpdatingPage extends StatefulWidget {
  const ActivelyUpdatingPage({ super.key });

  State<StatefulWidget> createState() => ActivelyUpdatingPageState();
}

class ActivelyUpdatingPageState extends State<ActivelyUpdatingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(YaruIcons.checkmark, color: YaruColors.adwaitaGreen, size: 60),
        const Text("Update Started", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: YaruColors.adwaitaGreen),),
        const Text("See notifications for progress")
      ],
    );

  }
}

class SystemUpdatesPage extends StatefulWidget {
  const SystemUpdatesPage({super.key});

  @override
  State<StatefulWidget> createState() => SystemUpdatesPageState();
}

class SystemUpdatesPageState extends State<SystemUpdatesPage> {
  LatestVersionInfo? latestVersionInfo;
  String? yourPlutoVersion;

  @override
  void initState() {
    super.initState();

    getLatestPlutoOSVersion();
    getYourPlutoOSVersion();
  }

  Future<void> getLatestPlutoOSVersion() async {
    latestVersionInfo = await PlutoosSystemLibrary.getLatestVersionInfo();
  }

  Future<void> getYourPlutoOSVersion() async {
    var version = await PlutoosSystemLibrary.getSystemInstalledPlutoOSVersion();
    setState(() { yourPlutoVersion = version; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 15,
        children: [


          if (latestVersionInfo != null && yourPlutoVersion != null) ...[
            if (PlutoosSystemLibrary.compareVersions(yourPlutoVersion!, latestVersionInfo!.stable.latestVersion)) ...[
              const Icon(YaruIcons.warning_filled, color: YaruColors.adwaitaRed, size: 60),
              const Text("System Update Available", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: YaruColors.adwaitaRed),),
            ] else ...[
              const Icon(YaruIcons.checkmark, color: YaruColors.adwaitaGreen, size: 60),
              const Text("System is Up to Date", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: YaruColors.adwaitaGreen),),
            ],
          ] else ...[
            const Text("Checking for Updates...", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
            const YaruLinearProgressIndicator(strokeWidth: 5)
          ],


          Center(
            child: Text(
              'PlutoOS generally releases new major updates once a month to ensure that you have the latest and greatest software.',
            ),
          ),



          Row(
            spacing: 100,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Text("Latest Pluto Version"),
              
                  if (latestVersionInfo == null)
                    const CircularProgressIndicator()
                  else
                    Text(latestVersionInfo!.stable.latestVersion),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Text("Your Pluto Version"),
                  if (yourPlutoVersion == null)
                    const CircularProgressIndicator()
                  else
                    Text(yourPlutoVersion!),
                ],
              ),
            ],
          ),

         
            if (latestVersionInfo != null &&
                yourPlutoVersion != null &&
                PlutoosSystemLibrary.compareVersions(yourPlutoVersion!, latestVersionInfo!.stable.latestVersion))
              Center(child:
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivelyUpdatingPage()));
                  },
                  child: const Text("Update Now"),
                ),
              )
          ],

      ),
    );
  }
}
