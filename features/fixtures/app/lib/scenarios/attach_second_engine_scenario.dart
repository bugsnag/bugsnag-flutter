import 'package:MazeRunner/channels.dart';
import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

/// Simulates an add-to-app host that runs each Flutter screen in its own
/// FlutterEngine. This (first) engine attaches and notifies, then asks the
/// native side to start a second engine, which runs [secondEngineMain].
class AttachSecondEngineScenario extends Scenario {
  @override
  Future<void> run() async {
    await startNativeNotifier();
    await bugsnag.attach();
    await bugsnag.notify(
      Exception('Handled exception from the first engine'),
      StackTrace.current,
    );

    await MazeRunnerChannels.runScenario('AttachSecondEngineScenario');
  }

  /// Runs in the second FlutterEngine, which has its own isolate and its own
  /// instance of the bugsnag_flutter plugin.
  static Future<void> secondEngineMain() async {
    await bugsnag.attach();
    await bugsnag.notify(
      Exception('Handled exception from the second engine'),
      StackTrace.current,
    );
    throw Exception('Unhandled exception from the second engine');
  }
}
