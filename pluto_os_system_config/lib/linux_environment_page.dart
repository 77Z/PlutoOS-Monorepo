import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yaru/yaru.dart';

class SupportedDistro {
  String prettyName;
  String logoAsset;
  String approxSize;
  String creationArguments;
  String distroBoxName;

  bool activelyInstalling = false;
  bool installed = false;

  SupportedDistro({
    required this.prettyName,
    required this.logoAsset,
    required this.approxSize,
    required this.creationArguments,
    required this.distroBoxName,
  });

  Future<bool> installDistro(VoidCallback onUpdate) async {
    activelyInstalling = true;
    onUpdate();

    final res = await Process.run("/usr/bin/bash", ["-c", "yes | /usr/bin/distrobox $creationArguments"]);

    print(res.stdout.toString());
    print(res.stderr.toString());

    activelyInstalling = false;
    if (res.exitCode == 0) installed = true;
    onUpdate();

    return res.exitCode == 0;
  }
}

class LinuxEnvironmentPage extends StatefulWidget {
  const LinuxEnvironmentPage({ super.key });

  @override
  State<StatefulWidget> createState() => LinuxEnvironmentPageState();
}

class LinuxEnvironmentPageState extends State<LinuxEnvironmentPage> {
  bool loading = true;

  List<SupportedDistro> distros = [
    SupportedDistro(
      prettyName: "Arch Linux",
      logoAsset: "assets/arch_logo.svg",
      approxSize: "~310 MiB",
      creationArguments: "create --image archlinux --name Pluto-Arch",
      distroBoxName: "Pluto-Arch",
    ),
    SupportedDistro(
      prettyName: "Ubuntu",
      logoAsset: "assets/ubuntu_logo.svg",
      approxSize: "~30 MiB",
      creationArguments: "create --image ubuntu --name Pluto-Ubuntu",
      distroBoxName: "Pluto-Ubuntu",
    ),
    SupportedDistro(
      prettyName: "Ubuntu (w/ systemd)",
      logoAsset: "assets/ubuntu_logo.svg",
      approxSize: "~30 MiB",
      creationArguments: 'create --image ubuntu --name Pluto-Ubuntu-systemd --additional-packages "systemd libpam-systemd pipewire-audio-client-libraries" --init',
      distroBoxName: "Pluto-Ubuntu-systemd",
    ),
    SupportedDistro(
      prettyName: "Fedora",
      logoAsset: "assets/fedora_logo.svg",
      approxSize: "~60 MiB",
      creationArguments: "create --image fedora --name Pluto-Fedora",
      distroBoxName: "Pluto-Fedora",
    ),
    SupportedDistro(
      prettyName: "Alpine",
      logoAsset: "assets/alpine_logo.svg",
      approxSize: "~3.5 MiB",
      creationArguments: "create --image alpine --name Pluto-Alpine",
      distroBoxName: "Pluto-Alpine"
    )
  ];

  @override
  void initState() {
    super.initState();

    loadInstalledDistros();
  }

  Future<void> loadInstalledDistros() async {
    final res = await Process.run("/usr/bin/distrobox", ["ls"]);

    final stdout = res.stdout.toString();

    for (int i = 0; i < distros.length; i++) {
      if (stdout.contains(distros[i].distroBoxName)) { distros[i].installed = true; }
    }

    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: loading ? Center(child: CircularProgressIndicator()) : ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Center(
            child: Text(
              'Linux Environments are lightweight distros that can run alongside PlutoOS using container magic and good integration. All of the distros provide you with a terminal and well integrated bridges to PlutoOS that allow you to utilize the power of any Linux distro on your machine.'
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            itemCount: distros.length,
            itemBuilder: (BuildContext context, int index) {
              return Card.filled(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      SvgPicture.asset(distros[index].logoAsset, semanticsLabel: "${distros[index].prettyName} Logo", width: 25),
                      Text(distros[index].prettyName, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Spacer(),

                      if (distros[index].installed) ... [
                        IconButton(onPressed: () {}, icon: Icon(YaruIcons.trash), tooltip: "Delete Distro",),
                        IconButton(
                          icon: Icon(YaruIcons.terminal),
                          tooltip: "Run Terminal Here",
                          onPressed: () =>
                            Process.start("/usr/bin/kitty", ["--title=Linux Environment: ${distros[index].prettyName}", "-e", "/usr/bin/distrobox", "enter", (distros[index].distroBoxName)])
                        ),
                      ] else ...[

                        if (distros[index].activelyInstalling) ...[
                          CircularProgressIndicator()
                        ] else ...[
                          Text(distros[index].approxSize, style: TextStyle(color: Colors.grey)),
                          ElevatedButton(child: const Text("Install"),
                            onPressed: () {
                              // setState(() { distros[index].installDistro(); });
                              distros[index].installDistro(() => setState(() {}));
                            })
                        ]

                      ]
                    ],
                  ),
                ),
              );
            },
          ),


          /* Column(
            children: [
              YaruRadioButton<String>(
                value: 'arch',
                groupValue: 'arch', // You'll want to make this stateful
                onChanged: (value) {
                  // Handle arch selection
                },
                title: Text('Arch-like'),
                subtitle: Text(
                  'Bleeding edge terminal updates and access to the pacman package manager.',
                ),
              ),
              YaruRadioButton<String>(
                value: 'ubuntu',
                groupValue: 'arch', // You'll want to make this stateful
                onChanged: (value) {
                  // Handle ubuntu selection
                },
                title: Text('Ubuntu-like'),
                subtitle: Text(
                  'More stable terminal and access to the apt package manager.',
                ),
              ),
            ],
          ), */
        ],
      ),
    );
  }
}
