import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

class LastRunInfoScenario extends Scenario {
  @override
  Future<void> clearPersistentData() async {
    // Don't clear persistent data - we want the previous crash to be reported
  }

  @override
  Future<void> run() async {
    await startBugsnag();

    await bugsnag.markLaunchCompleted();

    await bugsnag.notify(
      Exception('After launch'),
      null,
      callback: (event) async {
        final lastRunInfo =
            await bugsnag.getLastRunInfo() as BugsnagLastRunInfo;
        event.addMetadata('lastRunInfo', {
          'consecutiveLaunchCrashes': lastRunInfo.consecutiveLaunchCrashes,
          'crashed': lastRunInfo.crashed,
          'crashedDuringLaunch': lastRunInfo.crashedDuringLaunch,
        });
        return true;
      },
    );
  }
}
