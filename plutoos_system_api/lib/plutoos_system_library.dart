import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:plutoos_system_library/models/latest_version_info.dart';

class PlutoosSystemLibrary {

static bool systemInDevelopmentMode() {
  final devFile = File("/chainloader/DEV");

  return devFile.existsSync();
}

static String getAPIUrl() {
  return systemInDevelopmentMode()
    ? "http://localhost:8787/api/v1"
    : "https://pluto-freeze.77z.dev/api/v1";
}

// Returns true if PlutoOS is currently running on a Framework Laptop 13.
// TODO: Expand this to other frameworks as well!
static bool isFrameworkLaptop() {
  try {
    var manufacturer = File("/sys/devices/virtual/dmi/id/board_vendor");
    if (manufacturer.readAsStringSync() != "Framework\n") return false;

    var product = File("/sys/devices/virtual/dmi/id/product_name");
    if (!product.readAsStringSync().startsWith("Laptop")) return false;

    return true;

  } catch(e) {
    return false;
  }
}

static Future<LatestVersionInfo?> getLatestVersionInfo() async {
  var response = await http.get(Uri.parse("${getAPIUrl()}/latestVersions"));

  if (response.statusCode == 200) {
    return versionInfoFromJson(response.body);
  }
  return null;
}

static Future<String> getSystemInstalledPlutoOSVersion() async {
  final File versionFile = File("/pluto/version");

  if (!await versionFile.exists()) throw Exception("Version info doesn't exist? This isn't supposed to happen.");

  String versionRaw = versionFile.readAsStringSync();
  if (versionRaw.endsWith("\n")) versionRaw = versionRaw.replaceAll("\n", "");

  return versionRaw;

}

static bool compareVersions(String currentVer, String compareTo) {
  final currentParts = currentVer.split("-");
  final compareToParts = compareTo.split("-");

  if (currentParts.length != 2 || compareToParts.length != 2) {
    return false; // Invalid format
  }

  final currentYear = int.tryParse(currentParts[0]);
  final currentMonth = int.tryParse(currentParts[1]);
  final compareYear = int.tryParse(compareToParts[0]);
  final compareMonth = int.tryParse(compareToParts[1]);

  if (currentYear == null ||
      currentMonth == null ||
      compareYear == null ||
      compareMonth == null) {
    return false; // Invalid numbers
  }

  // Return true if current version is older than compareTo version
  if (currentYear < compareYear) {
    return true;
  } else if (currentYear == compareYear) {
    return currentMonth < compareMonth;
  }

  return true;
}

// Returns true if the user has put themselves in a PlutoOS update beta channel
static bool isInBetaChannel() {
  final betaFile = File("/chainloader/BETA");
  return betaFile.existsSync();
}

// Switches PlutoOS back to release updates
static Future<bool> removeSelfFromBetaChannel() async {
  final betaFile = File("/chainloader/BETA");
  betaFile.existsSync();

  final res = await Process.run("/pluto/pluto_update_manager", ["unenroll-from-beta"]);

  return res.exitCode == 0;
}

static Future<bool> setBetaChannel(String betaChannel) async {
  final res = await Process.run("/pluto/pluto_update_manager", ["switch-to-beta-channel", betaChannel]);

  return res.exitCode == 0;
}

}




// Also include:
// - get latest version from api
// - compare versions
// - get system version