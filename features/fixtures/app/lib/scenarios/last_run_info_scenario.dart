import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag.dart';

class LastRunInfoScenario extends Scenario {
  @override
  Future<void> clearPersistentData() async {
    // Don't clear persistent data - we want the previous crash to be reported
  }

  @override
  Future<void> run() async {
    await startBugsnag();

    await bugsnag.markLaunchComplete();

    await bugsnag.notify(Exception('After launch'), callback: (event) async {
      final lastRunInfo = await bugsnag.getLastRunInfo() as LastRunInfo;
      event.metadata.addMetadata('lastRunInfo', {
        'consecutiveLaunchCrashes': lastRunInfo.consecutiveLaunchCrashes,
        'crashed': lastRunInfo.crashed,
        'crashedDuringLaunch': lastRunInfo.crashedDuringLaunch,
      });
      return true;
    });
  }
}
