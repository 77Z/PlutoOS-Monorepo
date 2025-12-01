
import 'dart:convert';
import 'dart:io';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:proper_filesize/proper_filesize.dart';
import 'package:plutoos_system_library/plutoos_system_library.dart';

const int NOTIFICATION_ID = 45944594;

NotificationsClient? notifClient;

Future<void> downloadFileWithProgress(
  String url,
  String savePath,
  void Function(double progress, int bytesReceived, int bytesTotal) onProgress,
) async {
  final client = http.Client();
  try {
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }

    final contentLength = response.contentLength;
    final file = File(savePath);
    final sink = file.openWrite();

    int bytesReceived = 0;
    DateTime lastProgressTime = DateTime.now();


    await for (final chunk in response.stream) {
      sink.add(chunk);
      bytesReceived += chunk.length;
      if (contentLength != null) {
        final progress = bytesReceived / contentLength;

        final now = DateTime.now();
        if (now.difference(lastProgressTime).inMilliseconds >= 1000) {
          onProgress(progress, bytesReceived, contentLength);
          lastProgressTime = now;
        }
      } else {
        // content length is unknown :(
        // this can happen when running the update server on local miniflare.
      }
    }

    await sink.close();
    print('Download completed: $savePath');
  } finally {
    client.close();
  }
}



Future<bool> updateAvailable() async {
  return PlutoosSystemLibrary.compareVersions(
    await PlutoosSystemLibrary.getSystemInstalledPlutoOSVersion(),
    (await PlutoosSystemLibrary.getLatestVersionInfo())!.stable.latestVersion
  );
}

void showHelpAndDie() {

  print("""
      PlutoOS Update Manager
-------------------------------------
commands:
  check-for-update : prints 1 and exits with 0 if an update is available.
  invoke-update    : if there's an update, this will prompt the system to
                     download and install it. This also shows an update dialog
                     to the user.
  check-on-boot    : usually executed by a systemd timer, this will show a
                     notification to the user reminding them to update.
""");

  cleanExit(1);
}

Future<bool> executeUpdate(String targetVersion) async {

  // where should plutoos download the bundle to before installing?
  final updateBundleLocation = "/home/update.raucb";

  // is there a failed update that has yet to be deleted from the system?
  // get rid of it if so
  {
    final updateBundle = File(updateBundleLocation);
    if (updateBundle.existsSync()) {
      updateBundle.deleteSync();
      print("Existing update bundle file deleted");
    }
  }

  var keyString = File("/etc/rauc/authkey").readAsStringSync();

  await downloadFileWithProgress(
    "${PlutoosSystemLibrary.getAPIUrl()}/altDownload?key=$keyString&bundleName=PlutoOS-Update-$targetVersion.raucb",
    updateBundleLocation,
    (progress, bytesReceived, bytesTotal) {
      print("PROGRESS: ${(progress * 100.0).toInt()}");
      updatePercentDownloadedUI((progress * 100.0).toInt(), bytesReceived, bytesTotal);
    });
  
  final raucInfoProc = await Process.run("bash", [
    "-c",
    "rauc info $updateBundleLocation --keyring /etc/rauc/pluto-prod.cert.pem"
  ]);

  if (raucInfoProc.exitCode != 0) {
    await presentErrorToUser("Update corrupted after download :/");
    await cleanExit(1);
  }

  List<String> raucInfoOutput = raucInfoProc.stdout.toString().split("\n");

  bool bundleGood = false;
  for (var line in raucInfoOutput) {
    if (line.endsWith("'PlutoFreeze'")) {
      bundleGood = true;
      break;
    }
  }
  if (!bundleGood) {
    await presentErrorToUser("Update for the incorrect platform?");
    await cleanExit(1);
  }

  final updateSubprocess = await Process.start("bash", [
    "-c",
    "rauc install $updateBundleLocation"
  ]);

  updateSubprocess.stdout
    .transform(utf8.decoder)
    .listen((String data) {
      final match = RegExp(r'(\d+)%').firstMatch(data);
      if (match != null) {
        updatePercentCompleteUI(int.parse(match.group(1)!));
      }
    });

  final returnCode = await updateSubprocess.exitCode;

  if (returnCode != 0) {
    await presentErrorToUser("Update subprocess failed!");
    return false;
  }

  // delete update bundle now that it's installed.
  {
    final updateBundle = File(updateBundleLocation);
    if (updateBundle.existsSync()) updateBundle.deleteSync();
  }


  return true;
}

Future<void> presentErrorToUser(String error) async {
  print("Error presented: $error");
  await notifClient!.notify(
    "⚠️ Failed to update PlutoOS!",
    appName: "PlutoOS",
    body: error,
    replacesId: NOTIFICATION_ID,
    hints: [
      NotificationHint.urgency(NotificationUrgency.critical),
    ]
  );

  await cleanExit(1);
}

void updatePercentDownloadedUI(int percentage, int bytesReceived, int bytesTotal) {

  String prettyReceivedData = FileSize.fromBytes(bytesReceived).toString(unit: Unit.auto(size: bytesReceived, baseType: BaseType.binary));
  String prettyTotalData = FileSize.fromBytes(bytesTotal).toString(unit: Unit.auto(size: bytesTotal, baseType: BaseType.binary));

  notifClient!.notify(
    "Downloading PlutoOS Update...",
    appName: "PlutoOS",
    body: "$percentage% Downloaded • $prettyReceivedData of $prettyTotalData",
    replacesId: NOTIFICATION_ID,
    hints: [
      NotificationHint.urgency(NotificationUrgency.critical),
    ]
  );
}

void updatePercentCompleteUI(int percentage) {
  notifClient!.notify(
    "Updating PlutoOS...",
    appName: "PlutoOS",
    body: "$percentage%",
    replacesId: NOTIFICATION_ID,
    hints: [
      NotificationHint.urgency(NotificationUrgency.critical),
    ]
  );
}

Future<void> cleanExit(int returnCode) async {
  await notifClient!.close();
  exit(returnCode);
}

void main(List<String> arguments) async {
  notifClient = NotificationsClient();

  if (arguments.isEmpty) {
    showHelpAndDie();
  }
  
  switch (arguments[0]) {
    case "help":
    case "--help":
      showHelpAndDie();
      break;
    case "check-for-update":
      updateAvailable().then((v) {
        print(v ? "1": "0");
        exit(v ? 0 : 1);
      });
      break;

    case "invoke-update":
      print("Attempting to update system!");
      final versionInfo = await PlutoosSystemLibrary.getLatestVersionInfo();

      if (versionInfo == null) {
        await presentErrorToUser("Can't grab latest version info from server :/");
      }

      var currentVersion = await PlutoosSystemLibrary.getSystemInstalledPlutoOSVersion();
      var futureVersion = versionInfo!.stable.latestVersion;

      var newVerAvail = PlutoosSystemLibrary.compareVersions(currentVersion, futureVersion);

      print("$currentVersion --> $futureVersion");

      if (!newVerAvail) {
        print("This version isn't newer than the system, update isn't continuing.");
        await cleanExit(1);
      }

      final success = await executeUpdate(futureVersion);

      if (!success) await cleanExit(1);

      await notifClient!.notify(
        "PlutoOS Update Complete!",
        appName: "PlutoOS",
        body: "2025-15 → 2025-16\nRestart to use new version.",
        replacesId: NOTIFICATION_ID,
        hints: [
          NotificationHint.urgency(NotificationUrgency.critical),
        ]
      );

      await cleanExit(0);

      break;

    // invoked by a systemd timer on boot
    case "check-on-boot":
      var client = NotificationsClient();
      var notification = await client.notify(
        "PlutoOS Update Available",
        appIcon: "file:///usr/share/pixmaps/pluto-logo.png",
        appName: "PlutoOS",
        expireTimeoutMs: 60000,
        actions: [
          NotificationAction("update", "Update")
        ]
      );

      var actionKey = await notification.action.timeout(
        Duration(minutes: 1),
        // onTimeout: () {},
      );
      if (actionKey == "update") {
        // Process.run('pkexec', ['pluto_update_manager', 'invoke-update']);
        print("ah");
      }
      
      await client.close();
      break;

    case "test":
      var client = NotificationsClient();

      int progress = 1;

      while (true) {
        await client.notify(
          "Updating PlutoOS...",
          appName: "PlutoOS",
          body: "$progress%",
          replacesId: NOTIFICATION_ID,
          hints: [
            NotificationHint.urgency(NotificationUrgency.critical),
          ]
        );
        sleep(Duration(milliseconds: 100));
        progress++;

        if (progress == 100) break;
      }

      

      await client.close();
      break;

    default:
      print("command not found");
  }
}
