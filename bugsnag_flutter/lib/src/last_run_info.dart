class LastRunInfo {
  final int consecutiveLaunchCrashes;
  final bool crashed;
  final bool crashedDuringLaunch;

  LastRunInfo.fromJson(Map<String, dynamic> json)
      : consecutiveLaunchCrashes = json['consecutiveLaunchCrashes'] as int,
        crashed = json['crashed'] as bool,
        crashedDuringLaunch = json['crashedDuringLaunch'] as bool;
}
