import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class DiscardClassesScenario extends Scenario {
  @override
  Future<void> run() async {
    final withCallback = extraConfig?.contains('callback') == true;

    await bugsnag.start(
      endpoints: endpoints,
      discardClasses: {
        RegExp('_Exception'),
      },
    );
    try {
      throw Exception('this should be discarded');
    } catch (e, stack) {
      await _notifyError(e, stack, withCallback);
    }

    try {
      int.parse('this is not a number');
    } catch (e, stack) {
      await _notifyError(e, stack, withCallback);
    }

    if (extraConfig?.contains('unhandled') == true) {
      throw Exception('this should be discarded');
    }
  }

  Future<void> _notifyError(
    Object error,
    StackTrace stack,
    bool withCallback,
  ) async {
    await bugsnag.notify(
      error,
      stack,
      callback: withCallback
          ? (error) {
              error.addMetadata('origin', const {'callback': true});
              return true;
            }
          : null,
    );
  }
}
