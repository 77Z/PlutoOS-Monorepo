import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yaru/yaru.dart';

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        debugShowCheckedModeBanner: true,
        theme: yaru.theme,
        darkTheme: YaruThemeData().darkTheme,
        title: "Pluto Task Manager",
        home: _Home(),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaruWindowTitleBar(),
      body: YaruMasterDetailPage(
        length: 5,
        tileBuilder: (context, index, selected, availableWidth) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 9.0),
                  child: Text("System"),
                ),
                YaruMasterTile(
                  title: Text("Applications"),
                  leading: SvgPicture.asset("assets/apps.svg"),
                )
              ],
            );
          }

          if (index == 1) {
            return YaruMasterTile(
              title: const Text("Processes"),
              leading: SvgPicture.asset("assets/memory.svg"),
            );
          }

          if (index == 2) {
            return YaruMasterTile(
              title: const Text("Services"),
              leading: SvgPicture.asset("assets/database.svg"),
            );
          }

          if (index == 3) {
            return YaruMasterTile(
              title: const Text("Containers"),
              leading: SvgPicture.asset("assets/package-variant-closed.svg"),
            );
          }

          if (index == 4) {
            return YaruMasterTile(
              title: const Text("Device Manager"),
              leading: SvgPicture.asset("assets/browse_activity.svg"),
            );
          }

          throw Exception("Index misalligned?");
        },

        pageBuilder: (context, index) {
          if (index == 0) {
            return Center(child: Text("apps"),);
          }

          return Center(child: const Text("Failed to load page?"),);
        },
      ),
    );
  }

}