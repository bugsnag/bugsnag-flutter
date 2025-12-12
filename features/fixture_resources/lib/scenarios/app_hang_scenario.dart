import 'package:maze_runner/channels.dart';
import 'package:maze_runner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

class AppHangScenario extends Scenario {
  @override
  Future<void> run() async {
    if (extraConfig == 'enabled') {
      await bugsnag.start(
        appHangThresholdMillis: 2000,
        endpoints: endpoints,
      );
    } else {
      await startBugsnag();
    }
    await MazeRunnerChannels.platform.invokeMethod('appHang');
  }
}
