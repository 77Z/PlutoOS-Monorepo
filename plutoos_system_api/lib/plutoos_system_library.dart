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
    ? /*"http://192.168.1.38:8787/api/v1"*/ "http://172.25.21.239:8787/api/v1"
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

  String latestVersionsURL = "${getAPIUrl()}/latestVersions";

  if (isInBetaChannel()) {
    latestVersionsURL += "?channel=${getBetaChannel()}";
  }

  var response = await http.get(Uri.parse(latestVersionsURL));

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

static String? getBetaChannel() {
  if (!isInBetaChannel()) return null;
  return File("/chainloader/BETA").readAsStringSync();
}

}

class PlutoDevice {

  static bool isAMDFramework() {
    if (!PlutoosSystemLibrary.isFrameworkLaptop()) return false;

    final res = Process.runSync("lscpu", []);
    final split = res.stdout.toString().split("\n");

    for (final line in split) {
      if (line.startsWith("Vendor ID:") && line.contains("AuthenticAMD")) return true;
    }

    return false;
  }

  static bool isIntelFramework() {
    if (!PlutoosSystemLibrary.isFrameworkLaptop()) return false;

    final res = Process.runSync("lscpu", []);
    final split = res.stdout.toString().split("\n");

    for (final line in split) {
      if (line.startsWith("Vendor ID:") && line.contains("GenuineIntel")) return true;
    }

    return false;
  }

}

class PlutoOSPower {

  static String discoverBattery() {

    // discover all batteries

    List<FileSystemEntity> batteries = [];

    final powerSupplies = Directory("/sys/class/power_supply/").listSync();
    for (var item in powerSupplies) {
      if (item.path.contains("BAT")) batteries.add(item);
    }

    if (batteries.isEmpty) throw Exception("No batteries found");

    // TODO: we should look into picking the best battery to use if there is more than one.
    return batteries[0].path;
  }

  static double getBatteryDrawInWatts(String batterySysfsPath) {
    final powerNow = File("$batterySysfsPath/power_now");
    final voltageNow = File("$batterySysfsPath/voltage_now");
    final currentNow = File("$batterySysfsPath/current_now");

    double watts = -1;

    if (powerNow.existsSync()) {
      watts = double.parse(powerNow.readAsStringSync()) / 1000000.0;
    } else if (voltageNow.existsSync() && currentNow.existsSync()) {
      watts = double.parse(currentNow.readAsStringSync()) / 1000000.0 * double.parse(voltageNow.readAsStringSync()) / 1000000.0;
    }

    return watts;
  }

  static int getBatteryPercentage(String batterySysfsPath) {
    int percentage = -1;
    final capacity = File("$batterySysfsPath/capacity");

    if (capacity.existsSync()) percentage = int.parse(capacity.readAsStringSync().trim());

    return percentage;
  }

  static bool isBatteryCharging(String batterySysfsPath) {
    bool charging = false;
    final status = File("$batterySysfsPath/status");

    if (status.existsSync()) charging = status.readAsStringSync().trim() == "Charging";

    return charging;
  }

}
