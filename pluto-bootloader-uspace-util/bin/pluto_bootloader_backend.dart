/* 
  This program adheres to standards laid out in https://rauc.readthedocs.io/en/latest/integration.html#custom
 */

import 'dart:io';

import 'package:posix/posix.dart';

String grubEnvLocation = "/chainloader/grub/grubenv";

String? getPrimary() {
  final cmdlineFile = File("/proc/cmdline");
  final cmdline = cmdlineFile.readAsStringSync();

  if (cmdline.contains("rauc.slot=A")) return "A";
  if (cmdline.contains("rauc.slot=B")) return "B";

  return null;
}

enum Slot { A, B }

Future<bool> setPrimary(Slot slot) async {
  var stat1 = await Process.run("bash", ["-c", "grub-editenv $grubEnvLocation set A_TRY=${slot == Slot.A ? "1" : "0"}"]);
  var stat2 = await Process.run("bash", ["-c", "grub-editenv $grubEnvLocation set B_TRY=${slot == Slot.B ? "1" : "0"}"]);

  if (stat1.exitCode != 0 || stat2.exitCode != 0) return false;

  return true;
}

// returns true if state is good, false if bad, null if failed to check
Future<bool?> getState(Slot slot) async {
  final proc = await Process.run("bash", ["-c", "grub-editenv $grubEnvLocation list"]);

  if (proc.exitCode != 0) return null;

  final output = proc.stdout.toString().split("\n");

  for (var line in output) {
    if (line.startsWith("${slot == Slot.A ? "A" : "B"}_GOOD")) {
      return int.parse(line.split("=")[1]) == 1;
    }
  }

  return null;
}

// true if successfully set, false if not
Future<bool> setState(Slot slot, bool good) async {

  var stat1 = await Process.run("bash", ["-c", "grub-editenv $grubEnvLocation set ${slot == Slot.A ? "A" : "B"}_GOOD=${good ? "1" : "0"}"]);

  if (stat1.exitCode != 0) return false;

  return true;
}

void main(List<String> args) async {
  if (geteuid() != 0) {
    print("program should run as root");
    exit(1);
  }

  if (args.isEmpty) {
    print("need arguments (get-primary, set-primary, get-state, set-state)");
    exit(1);
  }

  // Special flag file that allows for rauc in the installer iso to use
  // this program despite grubenv being in a different location
  final grubenvOverrideFile = File("/DANGER-GRUBENV-OVERRIDE");
  if (grubenvOverrideFile.existsSync()) {
    grubEnvLocation = grubenvOverrideFile.readAsStringSync();
  }

  switch (args[0]) {
    case "get-primary":
      final primary = getPrimary();
      if (primary == null) exit(1);
      print(primary);
      break;

    case "set-primary":
      bool res = false;

      if (args.length != 2) exit(1);

      if (args[1] == "A") {
        res = await setPrimary(Slot.A);
      } else if (args[1] == "B") {
        res = await setPrimary(Slot.B);
      }

      exit(res ? 0 : 1);
      
      break;

    case "get-state":
      if (args.length != 2) exit(1);
      if (args[1] != "A" && args[1] != "B") exit(1);

      Slot targetSlot = Slot.A;
      if (args[1] == "B") targetSlot = Slot.B;

      var res = await getState(targetSlot);

      if (res == null) {
        exit(1);
        throw Error(); // throw never hits. counts as null-check for next line
      }

      print(res ? "good" : "bad");
      exit(0);
      break;

    case "set-state":
      if (args.length != 3) exit(1);
      if (args[1] != "A" && args[1] != "B") exit(1);
      if (args[2] != "good" && args[2] != "bad") exit(1);

      Slot targetSlot = Slot.A;
      if (args[1] == "B") targetSlot = Slot.B;

      exit(await setState(targetSlot, args[2] == "good") ? 0 : 1);

      break;

    default:
  }
}
