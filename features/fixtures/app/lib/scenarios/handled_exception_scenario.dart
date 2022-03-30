import 'package:bugsnag_flutter/bugsnag.dart';

import 'scenario.dart';

class HandledExceptionScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    try {
      throw Exception('test error message');
    } catch (e) {
      if (extraConfig?.contains('callback') == true) {
        await bugsnag.notify(e, callback: (event) {
          event.breadcrumbs = [Breadcrumb('Crumbs!')];
          event.metadata.addMetadata('callback', {'message': 'Hello, World!'});
          event.unhandled = true;
          return true;
        });
      } else {
        await bugsnag.notify(e);
      }
    }
  }
}
