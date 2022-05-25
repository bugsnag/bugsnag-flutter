import 'dart:async';

import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

class ErrorHandlerScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();

    if (extraConfig?.contains("zone") == true) {
      runZonedGuarded(
        () {
          String? nothingHere;
          nothingHere!.substring(0, 10);
        },
        bugsnag.errorHandler,
      );
    } else if (extraConfig?.contains("future") == true) {
      _throwAsyncException().onError(bugsnag.errorHandler);
    }
  }

  Future<void> _throwAsyncException() async {
    throw 'exception from the future';
  }
}
