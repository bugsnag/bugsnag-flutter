import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class OnErrorScenario extends Scenario {
  @override
  Future<void> run() async { 
    await bugsnag.start(
        endpoints: endpoints,
        onError: [
          (event) => event.errors.first.message != 'Ignored',
          (event) {
            event.app.id = 'app_id';
            event.device.id = 'device_id';
            event.severity = BugsnagSeverity.info;
            event.errors.first.message = 'Not ignored';
            return true;
          },
        ]
      );
    await bugsnag.notify(Exception('Ignored'), StackTrace.current);
    await bugsnag.notify(Exception('Test'), StackTrace.current);
  }
}
