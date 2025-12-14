import 'dart:io';

import 'package:flutter/material.dart';

class AdditionalDetails {
  String kernelVersion = "";
  String plutoExtensions = "";
  String plasmaVersion = "";
  String kdeFrameworksVersion = "";
  String deviceModel = "";

  // AdditionalDetails({
  //   required this.kernelVersion,
  //   required this.plutoExtensions,
  // });
}

class AboutPage extends StatefulWidget {
  const AboutPage({ super.key });

  @override
  State<StatefulWidget> createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  var details = AdditionalDetails();
  bool additionalDetailsReady = false;
  String buildNumber = "";

  @override
  void initState() {
    super.initState();

    getBuildNumber();

    loadAdditionalDetails();
  }

  Future<void> getBuildNumber() async {
    final f = File("/pluto/version");
    final version = (await f.readAsString()).trim();

    setState(() => buildNumber = version);
  }

  Future<void> loadAdditionalDetails() async {
    details.kernelVersion = (await File("/proc/version").readAsString()).trim().split(" ")[2];
    details.plasmaVersion = (await Process.run("/usr/bin/plasmashell", ["--version"])).stdout.toString().trim().split(" ")[1];
    details.kdeFrameworksVersion = (await Process.run("/usr/bin/kded6", ["--version"])).stdout.toString().trim().split(" ")[1];
    details.plutoExtensions = "0";

    details.deviceModel = "${(await File("/sys/class/dmi/id/board_vendor").readAsString()).trim()} ${(await File("/sys/class/dmi/id/product_name").readAsString()).trim()}";

    setState(() =>  additionalDetailsReady = true);
  }

  @override Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Image.file(File("/usr/share/pixmaps/pluto-logo-text.png"), alignment: AlignmentGeometry.center, height: 150,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("MAJOR RELEASE"),
              Text("Version 3", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
              if (buildNumber.isNotEmpty) Text(buildNumber),
              Divider(indent: 10, endIndent: 10, height: 25,),

              if (!additionalDetailsReady) ... [
                CircularProgressIndicator()
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Kernel Version"),
                          const Text("KDE Plasma Version"),
                          const Text("KDE Frameworks Version"),
                          const Text("PlutoOS Extensions"),
                          SizedBox(width: 10, height: 10),
                          const Text("Pluto Hardware Recipe"),
                          const Text("Device Model"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(details.kernelVersion),
                          SelectableText(details.plasmaVersion),
                          SelectableText(details.kdeFrameworksVersion),
                          SelectableText(details.plutoExtensions),
                          SizedBox(width: 10, height: 10),
                          SelectableText("LegacyIntelFmwrk"),
                          SelectableText(details.deviceModel, maxLines: 1,)
                        ],
                      ),
                    )
                  ],
                ),
              ]
            ]
          )
        ],
      ),
    );
  }
}