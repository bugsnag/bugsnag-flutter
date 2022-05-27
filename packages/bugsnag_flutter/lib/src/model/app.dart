import '_model_extensions.dart';

/// Stateless information set by the notifier about your app can be found on
/// this class. These values can be accessed and amended if necessary.
///
/// See also:
/// - [BugsnagAppWithState]
/// - [BugsnagEvent]
/// - [BugsnagDevice]
class BugsnagApp {
  /// The architecture of the running application binary
  String? binaryArch;

  /// The unique identifier for the build of the application
  String? buildUUID;

  /// iOS only: The app's bundleVersion, set from the CFBundleVersion.
  /// Equivalent to `versionCode` on Android.
  String? bundleVersion;

  /// iOS only: Unique identifier for the debug symbols file corresponding to
  /// the application
  List<String>? dsymUuids;

  /// The app identifier used by the application
  String? id;

  /// The release stage set in [Bugsnag.start]
  String? releaseStage;

  /// The application type set in [Bugsnag.start]
  String? type;

  /// The version of the application which can be set in [Bugsnag.start]
  String? version;

  /// Android only: the version code of the application from the
  /// `AndroidManifest.xml` or [Bugsnag.start]
  int? versionCode;

  BugsnagApp.fromJson(Map<String, Object?> json)
      : binaryArch = json.safeGet('binaryArch'),
        buildUUID = json.safeGet('buildUUID'),
        bundleVersion = json.safeGet('bundleVersion'),
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
        if (dsymUuids != null) 'dsymUUIDs': dsymUuids,
        if (id != null) 'id': id,
        if (releaseStage != null) 'releaseStage': releaseStage,
        if (type != null) 'type': type,
        if (version != null) 'version': version,
        if (versionCode != null) 'versionCode': versionCode,
      };
}

/// Stateful information set by the notifier about your app can be found on this
/// class. These values can be accessed and amended if necessary.
///
/// See also:
/// - [BugsnagApp]
/// - [BugsnagEvent]
/// - [BugsnagDevice]
class BugsnagAppWithState extends BugsnagApp {
  /// The number of milliseconds the application was running before the
  /// event occurred
  int? duration;

  /// The number of milliseconds the application was running in the foreground
  /// before the event occurred
  int? durationInForeground;

  /// Whether the application was in the foreground when the event occurred
  bool? inForeground;

  /// Whether the application was launching when the event occurred
  /// See also:
  /// - [Client.markLaunchCompleted]
  bool? isLaunching;

  BugsnagAppWithState.fromJson(Map<String, Object?> json)
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
