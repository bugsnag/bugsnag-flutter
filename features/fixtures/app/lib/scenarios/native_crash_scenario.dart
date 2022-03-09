import 'package:MazeRunner/channels.dart';

import 'scenario.dart';

class NativeCrashScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    await MazeRunnerChannels.runScenario("NativeCrashScenario");
  }
}
