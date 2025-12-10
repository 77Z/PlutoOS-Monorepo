import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class SupportedDistro {
  String prettyName;

  SupportedDistro({
    required this.prettyName
  });
}

class LinuxEnvironmentPage extends StatelessWidget {
  const LinuxEnvironmentPage({super.key});

  static List<SupportedDistro> distros = [
    SupportedDistro(prettyName: "Arch Linux"),
    SupportedDistro(prettyName: "Ubuntu"),
    SupportedDistro(prettyName: "Fedora"),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: Text(
              // 'The chosen Linux Environment of PlutoOS determines how things like native Linux applications and the terminal behaves. Typically, just pick the one you\'re most familiar with.',
              'Linux Environments are lightweight distros that can run alongside PlutoOS using container magic and good integration. All of the distros provide you with a terminal and well integrated bridges to PlutoOS that allow you to utilize the power of any Linux distro on your machine.'
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            itemCount: distros.length,
            itemBuilder: (BuildContext context, int index) {
              return Card.filled(
                // margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(distros[index].prettyName, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Spacer(),
                      ElevatedButton(onPressed: () {}, child: const Text("Install"))
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
