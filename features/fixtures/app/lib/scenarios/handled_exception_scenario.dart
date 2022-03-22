import 'package:bugsnag_flutter/bugsnag.dart';

import 'scenario.dart';

class HandledExceptionScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    try {
      throw Exception('test error message');
    } catch (e) {
      await bugsnag.notify(e);
    }
  }
}
