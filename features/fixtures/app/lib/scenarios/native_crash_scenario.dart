import 'package:MazeRunner/channels.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class NativeCrashScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      endpoints: endpoints,
      autoDetectErrors: extraConfig?.contains('noDetectErrors') != true,
    );

    await MazeRunnerChannels.runScenario('NativeCrashScenario');
  }
}
