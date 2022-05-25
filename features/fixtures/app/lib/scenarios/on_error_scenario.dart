import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class OnErrorScenario extends Scenario {
  @override
  Future<void> run() => bugsnag.start(
        endpoints: endpoints,
        onError: [
          (event) => event.errors.first.message != 'Ignored',
          (event) {
            event.errors.first.message = 'Not ignored';
            return true;
          },
        ],
        runApp: () async {
          await bugsnag.notify(Exception('Ignored'), StackTrace.current);
          await bugsnag.notify(Exception('Test'), StackTrace.current);
        },
      );
}
