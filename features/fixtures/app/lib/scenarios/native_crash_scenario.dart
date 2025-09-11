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
    //used in the Scenario: Grouping Discriminator in Native Event
    bugsnag.setGroupingDiscriminator("Native Grouping Discriminator");
    await MazeRunnerChannels.runScenario('NativeCrashScenario');
  }
}
