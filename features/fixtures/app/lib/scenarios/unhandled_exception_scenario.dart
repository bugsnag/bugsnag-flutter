import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter/scheduler.dart';

import 'scenario.dart';

class UnhandledExceptionScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      endpoints: endpoints,
      autoDetectErrors: extraConfig?.contains('noDetectErrors') != true,
    );

    // Schedule and await to force everything onto the flutter stack.
    await SchedulerBinding.instance?.scheduleTask(
      () {
        throw Exception('test error message');
      },
      Priority.animation,
    );
  }
}
