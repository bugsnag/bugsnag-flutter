import 'dart:async';

import 'package:bugsnag_flutter/bugsnag.dart';

import '../channels.dart';
import 'scenario.dart';

class DetectEnabledErrorsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      enabledErrorTypes: EnabledErrorTypes(
        unhandledDartExceptions:
            extraConfig?.contains('detectDartExceptions') == true,
        unhandledJvmExceptions:
            extraConfig?.contains('detectJvmExceptions') == true,
      ),
      endpoints: endpoints,
      runApp: () {
        Zone.root.run(_delayedNativeException);
        throw Exception('Exception from Dart');
      },
    );
  }

  Future<void> _delayedNativeException() async {
    await Future.delayed(const Duration(seconds: 1));
    await MazeRunnerChannels.runScenario('NativeCrashScenario');
  }
}
