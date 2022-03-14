library bugsnag;

import 'package:flutter/foundation.dart';

part 'json_object.dart';

class Device extends JsonObject {
  Device() : super();

  Device.fromJson(Map<String, Object?> json) : super.fromJson(json);

  List<String>? get cpuAbi => _json['cpuAbi'] as List<String>?;

  set cpuAbi(List<String>? value) => _json['cpuAbi'] = value;

  String? get id => _json['id'] as String?;

  set id(String? value) => _json['id'] = value;

  bool? get jailbroken => _json['jailbroken'] as bool?;

  set jailbroken(bool? value) => _json['jailbroken'] = value;

  String? get locale => _json['locale'] as String?;

  set locale(String? value) => _json['locale'] = value;

  String? get manufacturer => _json['manufacturer'] as String?;

  set manufacturer(String? value) => _json['manufacturer'] = value;

  String? get modelNumber => _json['modelNumber'] as String?;

  set modelNumber(String? value) => _json['modelNumber'] = value;

  String? get model => _json['model'] as String?;

  set model(String? value) => _json['model'] = value;

  String? get osName => _json['osName'] as String?;

  set osName(String? value) => _json['osName'] = value;

  String? get osVersion => _json['osVersion'] as String?;

  set osVersion(String? value) => _json['osVersion'] = value;

  Map<String, String>? get runtimeVersions =>
      _json['runtimeVersions'] as Map<String, String>?;

  set runtimeVersions(Map<String, String>? value) =>
      _json['runtimeVersions'] = value;

  int? get totalMemory => _json['totalMemory'] as int?;

  set totalMemory(int? value) => _json['totalMemory'] = value;
}

class DeviceWithState extends Device {
  DeviceWithState.fromJson(Map<String, Object?> json) : super.fromJson(json);

  int? get freeDisk => _json['freeDisk'] as int?;

  set freeDisk(int? value) => _json['freeDisk'] = value;

  int? get freeMemory => _json['freeMemory'] as int?;

  set freeMemory(int? value) => _json['freeMemory'] = value;

  String? get orientation => _json['orientation'] as String?;

  set orientation(String? value) => _json['orientation'] = value;

  DateTime? get time {
    Object? value = _json['time'];
    return value is String ? DateTime.parse(value) : null;
  }

  set time(DateTime? value) => _json['time'] = value?.toIso8601String();
}
