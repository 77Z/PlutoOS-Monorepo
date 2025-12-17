// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object /usr/share/dbus-1/interfaces/org.freedesktop.fwupd.xml

import 'dart:io';
import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.fwupd.Changed.
class OrgFreedesktopFwupdChanged extends DBusSignal {
  OrgFreedesktopFwupdChanged(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.fwupd.DeviceAdded.
class OrgFreedesktopFwupdDeviceAdded extends DBusSignal {
  Map<String, DBusValue> get device => values[0].asStringVariantDict();

  OrgFreedesktopFwupdDeviceAdded(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.fwupd.DeviceRemoved.
class OrgFreedesktopFwupdDeviceRemoved extends DBusSignal {
  Map<String, DBusValue> get device => values[0].asStringVariantDict();

  OrgFreedesktopFwupdDeviceRemoved(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.fwupd.DeviceChanged.
class OrgFreedesktopFwupdDeviceChanged extends DBusSignal {
  Map<String, DBusValue> get device => values[0].asStringVariantDict();

  OrgFreedesktopFwupdDeviceChanged(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

/// Signal data for org.freedesktop.fwupd.DeviceRequest.
class OrgFreedesktopFwupdDeviceRequest extends DBusSignal {
  Map<String, DBusValue> get request => values[0].asStringVariantDict();

  OrgFreedesktopFwupdDeviceRequest(DBusSignal signal) : super(sender: signal.sender, path: signal.path, interface: signal.interface, name: signal.name, values: signal.values);
}

class OrgFreedesktopFwupd extends DBusRemoteObject {
  /// Stream of org.freedesktop.fwupd.Changed signals.
  late final Stream<OrgFreedesktopFwupdChanged> changed;

  /// Stream of org.freedesktop.fwupd.DeviceAdded signals.
  late final Stream<OrgFreedesktopFwupdDeviceAdded> deviceAdded;

  /// Stream of org.freedesktop.fwupd.DeviceRemoved signals.
  late final Stream<OrgFreedesktopFwupdDeviceRemoved> deviceRemoved;

  /// Stream of org.freedesktop.fwupd.DeviceChanged signals.
  late final Stream<OrgFreedesktopFwupdDeviceChanged> deviceChanged;

  /// Stream of org.freedesktop.fwupd.DeviceRequest signals.
  late final Stream<OrgFreedesktopFwupdDeviceRequest> deviceRequest;

  OrgFreedesktopFwupd(DBusClient client, String destination, {DBusObjectPath path = const DBusObjectPath.unchecked('/')}) : super(client, name: destination, path: path) {
    changed = DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.fwupd', name: 'Changed', signature: DBusSignature('')).asBroadcastStream().map((signal) => OrgFreedesktopFwupdChanged(signal));

    deviceAdded = DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.fwupd', name: 'DeviceAdded', signature: DBusSignature('a{sv}')).asBroadcastStream().map((signal) => OrgFreedesktopFwupdDeviceAdded(signal));

    deviceRemoved = DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.fwupd', name: 'DeviceRemoved', signature: DBusSignature('a{sv}')).asBroadcastStream().map((signal) => OrgFreedesktopFwupdDeviceRemoved(signal));

    deviceChanged = DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.fwupd', name: 'DeviceChanged', signature: DBusSignature('a{sv}')).asBroadcastStream().map((signal) => OrgFreedesktopFwupdDeviceChanged(signal));

    deviceRequest = DBusRemoteObjectSignalStream(object: this, interface: 'org.freedesktop.fwupd', name: 'DeviceRequest', signature: DBusSignature('a{sv}')).asBroadcastStream().map((signal) => OrgFreedesktopFwupdDeviceRequest(signal));
  }

  /// Gets org.freedesktop.fwupd.DaemonVersion
  Future<String> getDaemonVersion() async {
    var value = await getProperty('org.freedesktop.fwupd', 'DaemonVersion', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.freedesktop.fwupd.HostBkc
  Future<String> getHostBkc() async {
    var value = await getProperty('org.freedesktop.fwupd', 'HostBkc', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.freedesktop.fwupd.HostVendor
  Future<String> getHostVendor() async {
    var value = await getProperty('org.freedesktop.fwupd', 'HostVendor', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.freedesktop.fwupd.HostProduct
  Future<String> getHostProduct() async {
    var value = await getProperty('org.freedesktop.fwupd', 'HostProduct', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.freedesktop.fwupd.HostMachineId
  Future<String> getHostMachineId() async {
    var value = await getProperty('org.freedesktop.fwupd', 'HostMachineId', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.freedesktop.fwupd.HostSecurityId
  Future<String> getHostSecurityId() async {
    var value = await getProperty('org.freedesktop.fwupd', 'HostSecurityId', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.freedesktop.fwupd.Tainted
  Future<bool> getTainted() async {
    var value = await getProperty('org.freedesktop.fwupd', 'Tainted', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.fwupd.Interactive
  Future<bool> getInteractive() async {
    var value = await getProperty('org.freedesktop.fwupd', 'Interactive', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.fwupd.Status
  Future<int> getStatus() async {
    var value = await getProperty('org.freedesktop.fwupd', 'Status', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.fwupd.Percentage
  Future<int> getPercentage() async {
    var value = await getProperty('org.freedesktop.fwupd', 'Percentage', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.fwupd.BatteryLevel
  Future<int> getBatteryLevel() async {
    var value = await getProperty('org.freedesktop.fwupd', 'BatteryLevel', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.fwupd.BatteryThreshold
  Future<int> getBatteryThreshold() async {
    var value = await getProperty('org.freedesktop.fwupd', 'BatteryThreshold', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.freedesktop.fwupd.OnlyTrusted
  Future<bool> getOnlyTrusted() async {
    var value = await getProperty('org.freedesktop.fwupd', 'OnlyTrusted', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.freedesktop.fwupd.Hwids
  Future<List<List<DBusValue>>> getHwids() async {
    var value = await getProperty('org.freedesktop.fwupd', 'Hwids', signature: DBusSignature('a(ss)'));
    return value.asArray().map((child) => child.asStruct()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetDevices()
  Future<List<Map<String, DBusValue>>> callGetDevices({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetDevices', [], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetPlugins()
  Future<List<Map<String, DBusValue>>> callGetPlugins({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetPlugins', [], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetReleases()
  Future<List<Map<String, DBusValue>>> callGetReleases(String device_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetReleases', [DBusString(device_id)], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetDowngrades()
  Future<List<Map<String, DBusValue>>> callGetDowngrades(String device_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetDowngrades', [DBusString(device_id)], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetUpgrades()
  Future<List<Map<String, DBusValue>>> callGetUpgrades(String device_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetUpgrades', [DBusString(device_id)], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetDetails()
  Future<List<Map<String, DBusValue>>> callGetDetails(ResourceHandle handle, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetDetails', [DBusUnixFd(handle)], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetHistory()
  Future<List<Map<String, DBusValue>>> callGetHistory({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetHistory', [], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetHostSecurityAttrs()
  Future<List<Map<String, DBusValue>>> callGetHostSecurityAttrs({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetHostSecurityAttrs', [], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetHostSecurityEvents()
  Future<List<Map<String, DBusValue>>> callGetHostSecurityEvents(int limit, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetHostSecurityEvents', [DBusUint32(limit)], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetReportMetadata()
  Future<Map<String, String>> callGetReportMetadata({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetReportMetadata', [], replySignature: DBusSignature('a{ss}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asDict().map((key, value) => MapEntry(key.asString(), value.asString()));
  }

  /// Invokes org.freedesktop.fwupd.SetHints()
  Future<void> callSetHints(Map<String, String> hints, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'SetHints', [DBusDict(DBusSignature('s'), DBusSignature('s'), hints.map((key, value) => MapEntry(DBusString(key), DBusString(value))))], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.Install()
  Future<void> callInstall(String id, ResourceHandle handle, Map<String, DBusValue> options, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'Install', [DBusString(id), DBusUnixFd(handle), DBusDict.stringVariant(options)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.Verify()
  Future<void> callVerify(String id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'Verify', [DBusString(id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.VerifyUpdate()
  Future<void> callVerifyUpdate(String id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'VerifyUpdate', [DBusString(id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.Unlock()
  Future<void> callUnlock(String id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'Unlock', [DBusString(id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.Activate()
  Future<void> callActivate(String id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'Activate', [DBusString(id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.GetResults()
  Future<Map<String, DBusValue>> callGetResults(String id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetResults', [DBusString(id)], replySignature: DBusSignature('a{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asStringVariantDict();
  }

  /// Invokes org.freedesktop.fwupd.GetRemotes()
  Future<List<Map<String, DBusValue>>> callGetRemotes({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetRemotes', [], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.GetApprovedFirmware()
  Future<List<String>> callGetApprovedFirmware({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetApprovedFirmware', [], replySignature: DBusSignature('as'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asStringArray().toList();
  }

  /// Invokes org.freedesktop.fwupd.SetApprovedFirmware()
  Future<void> callSetApprovedFirmware(List<String> checksums, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'SetApprovedFirmware', [DBusArray.string(checksums)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.GetBlockedFirmware()
  Future<List<String>> callGetBlockedFirmware({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetBlockedFirmware', [], replySignature: DBusSignature('as'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asStringArray().toList();
  }

  /// Invokes org.freedesktop.fwupd.SetBlockedFirmware()
  Future<void> callSetBlockedFirmware(List<String> checksums, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'SetBlockedFirmware', [DBusArray.string(checksums)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.SetFeatureFlags()
  Future<void> callSetFeatureFlags(int feature_flags, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'SetFeatureFlags', [DBusUint64(feature_flags)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.ClearResults()
  Future<void> callClearResults(String id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'ClearResults', [DBusString(id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.ModifyDevice()
  Future<void> callModifyDevice(String device_id, String key, String value, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'ModifyDevice', [DBusString(device_id), DBusString(key), DBusString(value)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.ModifyConfig()
  Future<void> callModifyConfig(String section, String key, String value, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'ModifyConfig', [DBusString(section), DBusString(key), DBusString(value)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.ResetConfig()
  Future<void> callResetConfig(String section, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'ResetConfig', [DBusString(section)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.UpdateMetadata()
  Future<void> callUpdateMetadata(String remote_id, ResourceHandle data, ResourceHandle signature, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'UpdateMetadata', [DBusString(remote_id), DBusUnixFd(data), DBusUnixFd(signature)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.ModifyRemote()
  Future<void> callModifyRemote(String remote_id, String key, String value, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'ModifyRemote', [DBusString(remote_id), DBusString(key), DBusString(value)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.CleanRemote()
  Future<void> callCleanRemote(String remote_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'CleanRemote', [DBusString(remote_id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.FixHostSecurityAttr()
  Future<void> callFixHostSecurityAttr(String appstream_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'FixHostSecurityAttr', [DBusString(appstream_id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.UndoHostSecurityAttr()
  Future<void> callUndoHostSecurityAttr(String appstream_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'UndoHostSecurityAttr', [DBusString(appstream_id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.SelfSign()
  Future<String> callSelfSign(String data, Map<String, DBusValue> options, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'SelfSign', [DBusString(data), DBusDict.stringVariant(options)], replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.fwupd.SetBiosSettings()
  Future<void> callSetBiosSettings(Map<String, String> settings, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'SetBiosSettings', [DBusDict(DBusSignature('s'), DBusSignature('s'), settings.map((key, value) => MapEntry(DBusString(key), DBusString(value))))], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.GetBiosSettings()
  Future<List<Map<String, DBusValue>>> callGetBiosSettings({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'GetBiosSettings', [], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }

  /// Invokes org.freedesktop.fwupd.Inhibit()
  Future<String> callInhibit(String reason, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'Inhibit', [DBusString(reason)], replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Invokes org.freedesktop.fwupd.Uninhibit()
  Future<void> callUninhibit(String inhibit_id, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'Uninhibit', [DBusString(inhibit_id)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.Quit()
  Future<void> callQuit({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'Quit', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.EmulationLoad()
  Future<void> callEmulationLoad(ResourceHandle handle, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'EmulationLoad', [DBusUnixFd(handle)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.EmulationSave()
  Future<void> callEmulationSave(ResourceHandle handle, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.fwupd', 'EmulationSave', [DBusUnixFd(handle)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.fwupd.Search()
  Future<List<Map<String, DBusValue>>> callSearch(String token, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.fwupd', 'Search', [DBusString(token)], replySignature: DBusSignature('aa{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asArray().map((child) => child.asStringVariantDict()).toList();
  }
}
