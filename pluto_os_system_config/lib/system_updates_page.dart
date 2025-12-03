import 'package:flutter/material.dart';
import 'package:plutoos_system_library/models/latest_version_info.dart';
import 'package:plutoos_system_library/plutoos_system_library.dart';
import 'package:yaru/yaru.dart';

class ActivelyUpdatingPage extends StatefulWidget {
  const ActivelyUpdatingPage({ super.key });

  @override
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

/* -------- Beta Settings -------- */

class BetaSettingsPage extends StatefulWidget {
  const BetaSettingsPage({ super.key });

  @override
  State<StatefulWidget> createState() => BetaSettingsPageState();
}

class BetaSettingsPageState extends State<BetaSettingsPage> {
  String betaChannel = "";

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
                const Text("PlutoOS Beta Builds", style: TextStyle(fontSize: 25))
              ],
            ),
        
            /* Page contents */
            Row(
              spacing: 15,
              children: [
                const Text("Beta channel ID code"),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(labelText: "code..."),
                    onChanged: (value) => betaChannel = value,
                  ),
                ),
                ElevatedButton(
                  child: const Text("Switch channel"),
                  onPressed: () {
                    PlutoosSystemLibrary.setBetaChannel(betaChannel).then((res) {
                      final snackBar = SnackBar(
                        content: Text('Switched to channel: $betaChannel', style: TextStyle(fontSize: 23, color: Colors.black), textAlign: TextAlign.center),
                        backgroundColor: Colors.white,
                      );

                      // Needed cause we're using context across async
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      // Navigator.pop(context);
                    });

                  }
                )
              ]
            ),

            if (PlutoosSystemLibrary.isInBetaChannel()) ...[
              Row(
                children: [
                  const Text("Currently enrolled in channel: ..."),
                  TextButton(
                    onPressed: () =>
                      PlutoosSystemLibrary.removeSelfFromBetaChannel()
                      .then((x) => context.mounted ? Navigator.pop(context) : null),
                    child: const Text("Unenroll")
                  )
                ],
              )
            ],
      
            Spacer(),
      
            Row(
              children: [
                const Text("Force an update to downgrade a version when switching from beta back to release"),
                Spacer(),
                ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivelyUpdatingPage())), child: const Text("Force invoke update"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/* -------- Main Page -------- */


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
      padding: const EdgeInsets.all(25.0),
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

          if (PlutoosSystemLibrary.isInBetaChannel()) ...[
            YaruInfoBox(
              yaruInfoType: YaruInfoType.warning,
              icon: Icon(YaruIcons.warning),
              child: const Text("You're currently enrolled in a beta channel. All system updates will come from this channel as long as you're enrolled. Beta PlutoOS versions can be unstable, so use these with caution."),
            ),
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
              ),

            Spacer(),

            Row(children: [
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BetaSettingsPage())),
                  child: const Text("Beta Builds"),
                )
              ],
            ),
          ],

      ),
    );
  }
}
