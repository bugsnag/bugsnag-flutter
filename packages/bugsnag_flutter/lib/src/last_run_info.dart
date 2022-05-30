/// Provides information about the last launch of the application, if there was one.
class BugsnagLastRunInfo {
  ///  The number times the app has consecutively crashed during its launch period.
  final int consecutiveLaunchCrashes;

  /// Whether the last app run ended with a crash, or was abnormally terminated
  /// by the system.
  final bool crashed;

  /// True if the previous app run ended with a crash during its launch period.
  final bool crashedDuringLaunch;

  BugsnagLastRunInfo.fromJson(Map<String, dynamic> json)
      : consecutiveLaunchCrashes = json['consecutiveLaunchCrashes'] as int,
        crashed = json['crashed'] as bool,
        crashedDuringLaunch = json['crashedDuringLaunch'] as bool;
}
