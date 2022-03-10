library bugsnag;

import 'package:flutter/foundation.dart';

part 'json_object.dart';

class App extends JsonObject {
  App() : super();

  App.fromJson(Map<String, Object?> json) : super.fromJson(json);

  String? get binaryArch => _json['binaryArch'] as String?;
  set binaryArch(String? value) => _json['binaryArch'] = value;

  String? get buildUUID => _json['buildUUID'] as String?;
  set buildUUID(String? value) => _json['buildUUID'] = value;

  String? get bundleVersion => _json['bundleVersion'] as String?;
  set bundleVersion(String? value) => _json['bundleVersion'] = value;

  String? get codeBundleId => _json['codeBundleId'] as String?;
  set codeBundleId(String? value) => _json['codeBundleId'] = value;

  List<String>? get dsymUUIDs => _json['dsymUUIDs'] as List<String>?;
  set dsymUUIDs(List<String>? value) => _json['dsymUUIDs'] = value;

  String? get id => _json['id'] as String?;
  set id(String? value) => _json['id'] = value;

  String? get releaseStage => _json['releaseStage'] as String?;
  set releaseStage(String? value) => _json['releaseStage'] = value;

  String? get type => _json['type'] as String?;
  set type(String? value) => _json['type'] = value;

  String? get version => _json['version'] as String?;
  set version(String? value) => _json['version'] = value;

  int? get versionCode => _json['versionCode'] as int?;
  set versionCode(int? value) => _json['versionCode'] = value;
}

class AppWithState extends App {
  AppWithState.fromJson(Map<String, Object?> json) : super.fromJson(json);

  int? get duration => _json['duration'] as int?;
  set duration(int? value) => _json['duration'] = value;

  int? get durationInForeground => _json['durationInForeground'] as int?;
  set durationInForeground(int? value) => _json['durationInForeground'] = value;

  bool? get inForeground => _json['inForeground'] as bool?;
  set inForeground(bool? value) => _json['inForeground'] = value;

  bool? get isLaunching => _json['isLaunching'] as bool?;
  set isLaunching(bool? value) => _json['isLaunching'] = value;
}
