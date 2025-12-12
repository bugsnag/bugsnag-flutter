import 'dart:async';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import '../channels.dart';
import 'scenario.dart';

class DetectEnabledErrorsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      enabledErrorTypes: BugsnagEnabledErrorTypes(
        unhandledDartExceptions:
            extraConfig?.contains('detectDartExceptions') == true,
        unhandledJvmExceptions:
            extraConfig?.contains('detectJvmExceptions') == true,
      ),
      endpoints: endpoints
    );
    Zone.root.run(_delayedNativeException);
    throw Exception('Exception from Dart');
  }

  Future<void> _delayedNativeException() async {
    await Future.delayed(const Duration(seconds: 1));
    await MazeRunnerChannels.runScenario('NativeCrashScenario');
  }
}
