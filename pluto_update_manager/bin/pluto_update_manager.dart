
import 'dart:convert';
import 'dart:io';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:plutoos_system_library/plutoos_system_library.dart';
import 'package:posix/posix.dart' as posix;
import 'package:proper_filesize/proper_filesize.dart';

Future<void> downloadFileWithProgress(
  String url,
  String savePath,
  void Function(double progress, int bytesReceived, int bytesTotal, bool contentLengthUnknown) onProgress,
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

    bool unknownContentLengthNotifSent = false;


    await for (final chunk in response.stream) {
      sink.add(chunk);
      bytesReceived += chunk.length;
      if (contentLength != null) {
        final progress = bytesReceived / contentLength;

        final now = DateTime.now();
        if (now.difference(lastProgressTime).inMilliseconds >= 1000) {
          onProgress(progress, bytesReceived, contentLength, false);
          lastProgressTime = now;
        }
      } else {
        // content length is unknown :(
        // this can happen when running the update server on local miniflare.
        if (!unknownContentLengthNotifSent) {
          onProgress(0, 0, 0, true);
          unknownContentLengthNotifSent = true;
        }
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

  exit(1);
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
    (progress, bytesReceived, bytesTotal, contentLengthUnknown) {
      if (contentLengthUnknown) {
        sendNotification(
          "Downloading PlutoOS Update...",
          body: "Progress unknown, please wait...",
        );
      } else {
        print("PROGRESS: ${(progress * 100.0).toInt()}");
        updatePercentDownloadedUI((progress * 100.0).toInt(), bytesReceived, bytesTotal);
      }
    });
  
  final raucInfoProc = await Process.run("bash", [
    "-c",
    "rauc info $updateBundleLocation --keyring /etc/rauc/pluto-prod.cert.pem"
  ]);

  if (raucInfoProc.exitCode != 0) {
    await presentErrorToUser("Update corrupted after download :/");
    exit(1);
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
    exit(1);
  }

  // before we start, we need to capture the drive labels associated
  // devs to reassign them after bundle installation.
  final EFIAdevPath = File("/dev/disk/by-label/EFIA").resolveSymbolicLinksSync();
  final EFIBdevPath = File("/dev/disk/by-label/EFIB").resolveSymbolicLinksSync();
  final ROOTAdevPath = File("/dev/disk/by-label/ROOTA").resolveSymbolicLinksSync();
  final ROOTBdevPath = File("/dev/disk/by-label/ROOTB").resolveSymbolicLinksSync();

  final updateSubprocess = await Process.start("bash", [
    "-c",
    "rauc install $updateBundleLocation"
    // "/code/PlutoDevelopment/PlutoOS-Monorepo/pluto_update_manager/bin/fakeprogress.sh"
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

  // reassign labels captured earlier
  // btrfs doesn't like when you use the device names directly when they're mounted,
  // but in this case it doesn't really matter cause the one that's mounted is already
  // labelled, so one of these will fail and that's okay.
  await Process.run("bash", ["-c", "btrfs filesystem label $ROOTAdevPath ROOTA"]);
  await Process.run("bash", ["-c", "btrfs filesystem label $ROOTBdevPath ROOTB"]);

  await Process.run("bash", ["-c", "e2label $EFIAdevPath EFIA"]);
  await Process.run("bash", ["-c", "e2label $EFIBdevPath EFIB"]);

  await Process.run("udevadm", ["trigger"]);


  return true;
}

Future<void> presentErrorToUser(String error) async {
  print("Error presented: $error");
  await sendNotification(
    "⚠️ Failed to update PlutoOS!",
    body: error,
  );

  exit(1);
}

void updatePercentDownloadedUI(int percentage, int bytesReceived, int bytesTotal) {

  String prettyReceivedData = FileSize.fromBytes(bytesReceived).toString(unit: Unit.auto(size: bytesReceived, baseType: BaseType.binary));
  String prettyTotalData = FileSize.fromBytes(bytesTotal).toString(unit: Unit.auto(size: bytesTotal, baseType: BaseType.binary));

  sendNotification(
    "Downloading PlutoOS Update...",
    body: "$percentage% Downloaded • $prettyReceivedData of $prettyTotalData",
  );
}

void updatePercentCompleteUI(int percentage) {
  sendNotification(
    "Updating PlutoOS...",
    body: "$percentage%",
  );
}

// Sets up this root ran application to be able to use notifications on the user's account
/* Future<void> subroutineNeedsNotifications() async {
  final String socketPath = "/tmp/pluto_notifs.unix";

  // Does the socket already exist? If so, we'll have to clean up.
  // This might happen if the child process can't close properly
  {
    final socket = File(socketPath);
    if (await socket.exists()) await socket.delete();
  }

  // Start up child notification helper
  Process.run("/usr/bin/sudo", [
    "--user=#1000",
    "/pluto/update_notification_helper"
  ]);

  // Wait for the child process to open a socket
  while (!await File(socketPath).exists()) {
    await Future.delayed(Duration(milliseconds: 100));
  }

  final socket = await connect(socketPath);
  socket.add(utf8.encode("string"));
} */

DateTime lastNotificationSentTime = DateTime.now();

Future<void> sendNotification(String summary,
  {String body = '',
  int expireTimeoutMs = -1,
  int replacesId = 0 }) async{
    final now = DateTime.now();
    if (now.difference(lastNotificationSentTime).inMilliseconds >= 1000) {
      print("[PUM] $summary : $body");

      await Process.run("/usr/bin/sudo", [
        "--user=#1000",
        "/pluto/update_notification_helper",
        summary,
        body,
        expireTimeoutMs.toString(),
      ]);
    }
  }

void main(List<String> arguments) async {

/*   var dbus = DBusClient(
      DBusAddress(
          "unix:path=/run/user/1000/bus"));
          // "unix:path=/tmp/pluto_dbus_proxy"));

  notifClient = NotificationsClient(bus: dbus);
 */
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

      // We're assuming now that if the user can run this command,
      // they absolutely do want to update the system
      /* if (!newVerAvail) {
        print("This version isn't newer than the system, update isn't continuing.");
        exit(1);
      } */

      final success = await executeUpdate(futureVersion);

      if (!success) exit(1);

      await sendNotification(
        "PlutoOS Update Complete!",
        body: "$currentVersion → $futureVersion\nRestart to use new version.",
      );

      exit(0);

    // invoked by a systemd timer on boot
    case "check-on-boot":
      if (posix.geteuid() != 1000) {
        print("This subroutine should run as normal user");
        exit(1);
      }

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






    case "switch-to-beta-channel":
      if (arguments.length != 2) exit(1);

      final betaFile = File("/chainloader/BETA");
      // Clear existing if any
      if (betaFile.existsSync()) betaFile.deleteSync();

      betaFile.writeAsStringSync(arguments[1]);

      break;

    case "unenroll-from-beta":
      final betaFile = File("/chainloader/BETA");
      if (betaFile.existsSync()) betaFile.deleteSync();
      break;

    case "get-beta-channel":
      final betaFile = File("/chainloader/BETA");
      if (!betaFile.existsSync()) exit(1);
      print(betaFile.readAsStringSync());
      break;

    default:
      print("command not found");
  }
}
