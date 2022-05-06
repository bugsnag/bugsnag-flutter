import '_model_extensions.dart';

class App {
  String? binaryArch;
  String? buildUUID;
  String? bundleVersion;
  String? codeBundleId;
  List<String>? dsymUuids;
  String? id;
  String? releaseStage;
  String? type;
  String? version;
  int? versionCode;

  App.fromJson(Map<String, Object?> json)
      : binaryArch = json.safeGet('binaryArch'),
        buildUUID = json.safeGet('buildUUID'),
        bundleVersion = json.safeGet('bundleVersion'),
        codeBundleId = json.safeGet('codeBundleId'),
        dsymUuids = json
            .safeGet<List>('dsymUUIDs')
            ?.cast<String>()
            .toList(growable: true),
        id = json.safeGet('id'),
        releaseStage = json.safeGet('releaseStage'),
        type = json.safeGet('type'),
        version = json.safeGet('version'),
        versionCode = json.safeGet<num>('versionCode')?.toInt();

  dynamic toJson() => {
        if (binaryArch != null) 'binaryArch': binaryArch,
        if (buildUUID != null) 'buildUUID': buildUUID,
        if (bundleVersion != null) 'bundleVersion': bundleVersion,
        if (codeBundleId != null) 'codeBundleId': codeBundleId,
        if (dsymUuids != null) 'dsymUUIDs': dsymUuids,
        if (id != null) 'id': id,
        if (releaseStage != null) 'releaseStage': releaseStage,
        if (type != null) 'type': type,
        if (version != null) 'version': version,
        if (versionCode != null) 'versionCode': versionCode,
      };
}

class AppWithState extends App {
  int? duration;
  int? durationInForeground;
  bool? inForeground;
  bool? isLaunching;

  AppWithState.fromJson(Map<String, Object?> json)
      : duration = json.safeGet<num>('duration')?.toInt(),
        durationInForeground =
            json.safeGet<num>('durationInForeground')?.toInt(),
        inForeground = json.safeGet('inForeground'),
        isLaunching = json.safeGet('isLaunching'),
        super.fromJson(json);

  @override
  dynamic toJson() => {
        for (final entry in (super.toJson() as Map<String, dynamic>).entries)
          entry.key: entry.value,
        if (duration != null) 'duration': duration,
        if (durationInForeground != null)
          'durationInForeground': durationInForeground,
        if (inForeground != null) 'inForeground': inForeground,
        if (isLaunching != null) 'isLaunching': isLaunching,
      };
}
