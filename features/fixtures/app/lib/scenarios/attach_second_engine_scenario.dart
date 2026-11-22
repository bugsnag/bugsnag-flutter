import 'package:MazeRunner/channels.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class AttachSecondEngineScenario extends Scenario {
  @override
  Future<void> run() async {
    await startNativeNotifier();
    await bugsnag.attach();
    await bugsnag.notify(
      Exception('Handled exception from first engine'),
      StackTrace.current,
    );
    await MazeRunnerChannels.runScenario('AttachSecondEngineScenario');
  }
}

/// Entry point run by the native AttachSecondEngineScenario in a new FlutterEngine
@pragma('vm:entry-point')
Future<void> secondEngineMain() async {
  await bugsnag.attach();
  await bugsnag.notify(
    Exception('Handled exception from second engine'),
    StackTrace.current,
  );
}
