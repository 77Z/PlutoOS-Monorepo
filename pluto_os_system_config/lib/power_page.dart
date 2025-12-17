import 'package:flutter/material.dart';
import 'package:plutoos_system_library/plutoos_system_library.dart';
import 'package:yaru/yaru.dart';

IconData getCorrespondingBatteryIcon(int percentage, bool chargingVariant) {
  if (percentage == -1) return YaruIcons.battery_missing;

  if (percentage == 100) return YaruIcons.battery_full;

  switch (percentage.toString()[0]) {
    case "1": return chargingVariant ? YaruIcons.battery_1_charging : YaruIcons.battery_1;
    case "2": return chargingVariant ? YaruIcons.battery_2_charging : YaruIcons.battery_2;
    case "3": return chargingVariant ? YaruIcons.battery_3_charging : YaruIcons.battery_3;
    case "4": return chargingVariant ? YaruIcons.battery_4_charging : YaruIcons.battery_4;
    case "5": return chargingVariant ? YaruIcons.battery_5_charging : YaruIcons.battery_5;
    case "6": return chargingVariant ? YaruIcons.battery_6_charging : YaruIcons.battery_6;
    case "7": return chargingVariant ? YaruIcons.battery_7_charging : YaruIcons.battery_7;
    case "8": return chargingVariant ? YaruIcons.battery_8_charging : YaruIcons.battery_8;
    case "9": return chargingVariant ? YaruIcons.battery_9_charging : YaruIcons.battery_9;
  }

  return YaruIcons.battery_missing;
}

class PowerPage extends StatefulWidget {
  const PowerPage({ super.key });

  @override State<StatefulWidget> createState() => PowerPageState();
}

class PowerPageState extends State<PowerPage> {

  String batteryPath = PlutoOSPower.discoverBattery();

  bool halfRateShading = false;
  bool downclockMemory = false;
  bool smartCoreShutdown = false;
  bool boreEnabled = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: [
          Row(
            children: [
              Icon(getCorrespondingBatteryIcon(PlutoOSPower.getBatteryPercentage(batteryPath), PlutoOSPower.isBatteryCharging(batteryPath)), size: 50),
              Text("${PlutoOSPower.getBatteryPercentage(batteryPath)}%", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
              Spacer(),
              Text("${(PlutoOSPower.getBatteryDrawInWatts(batteryPath) * 10).round() / 10} W", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
              Icon(PlutoOSPower.isBatteryCharging(batteryPath) ? YaruIcons.arrow_up : YaruIcons.arrow_down, size: 50)
            ],
          ),
          ElevatedButton(onPressed: () { setState(() {}); }, child: const Text("Reload")),
          Row(
            children: [
              Text("GPU Half-Rate Shading"),
              Spacer(),
              Switch(value: halfRateShading, onChanged: (v) => setState(() => halfRateShading = v)),
            ],
          ),
          Row(
            children: [
              Text("Downclock Memory"),
              Spacer(),
              Switch(value: downclockMemory, onChanged: (v) => setState(() => downclockMemory = v)),
            ],
          ),
          Row(
            children: [
              Tooltip(message: "Disables cores on the CPU when not under heavy use", child: Text("PlutoOS Smart Core Shutdown")),
              Spacer(),
              Switch(value: smartCoreShutdown, onChanged: (v) => setState(() => smartCoreShutdown = v)),
            ],
          ),
          Row(
            children: [
              Text("Burst-Oriented CPU Scheduler"),
              Spacer(),
              Switch(value: boreEnabled, onChanged: (v) => setState(() => boreEnabled = v)),
            ],
          ),
          if (smartCoreShutdown) Text("Prioritizes shutting down P-cores if they're available on your CPU. Disable this setting if you notice system instability.")
        ],
      ),
    );
  }
}