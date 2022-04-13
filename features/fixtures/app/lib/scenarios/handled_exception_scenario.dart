import 'package:bugsnag_flutter/bugsnag.dart';

import 'scenario.dart';

class HandledExceptionScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    try {
      throw Exception('test error message');
    } catch (e, stack) {
      if (extraConfig?.contains('callback') == true) {
        await bugsnag.notify(e, stack, callback: (event) {
          event.breadcrumbs = [BugsnagBreadcrumb('Crumbs!')];
          event.addMetadata('callback', {'message': 'Hello, World!'});
          event.setUser(
            id: '3',
            email: 'bugs.nag@bugsnag.com',
            name: 'Bugs Nag',
          );
          event.unhandled = true;
          return true;
        });
      } else {
        await bugsnag.notify(e, stack);
      }
    }
  }
}
