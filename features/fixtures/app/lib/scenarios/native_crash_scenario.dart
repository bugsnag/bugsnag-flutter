import 'package:MazeRunner/channels.dart';

import 'scenario.dart';

class NativeCrashScenario extends Scenario {
  @override
  Future<void> run() async {
    // TODO: I think I would factor startBugsnag() out of the scenarios and into main to avoid repetition
    await startBugsnag();
    await MazeRunnerChannels.runScenario("NativeCrashScenario");
  }
}
