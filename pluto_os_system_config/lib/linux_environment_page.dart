import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class LinuxEnvironmentPage extends StatelessWidget {
  const LinuxEnvironmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: Text(
              'The chosen Linux Environment of PlutoOS determines how things like native Linux applications and the terminal behaves. Typically, just pick the one you\'re most familiar with.',
            ),
          ),
          Column(
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
          ),
        ],
      ),
    );
  }
}
