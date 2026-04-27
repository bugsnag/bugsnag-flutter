import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class CallBugsnagBeforeStartScenario extends Scenario {
  @override
  Future<void> run() async {
    // This scenario demonstrates the isStarted property: developers can check
    // initialization state before calling Bugsnag methods, avoiding exceptions
    // and enabling graceful handling of pre-init calls.

    // Verify isStarted is false before initialization
    if (bugsnag.isStarted) {
      throw AssertionError(
        'Expected bugsnag.isStarted to be false before start(), '
        'but it was true. This indicates bugsnag was already initialized.'
      );
    }

    // Initialize Bugsnag via MazeRunner endpoints to avoid sending to
    // production endpoints during fixture runs.
    await bugsnag.start(
      endpoints: endpoints,
      autoTrackSessions: false,
    );

    // Verify isStarted is true after initialization
    if (!bugsnag.isStarted) {
      throw AssertionError(
        'Expected bugsnag.isStarted to be true after start(), '
        'but it was false.'
      );
    }

    // Now that we've verified initialization, methods should succeed
    // without throwing exceptions

    // Call setContext - should succeed
    await bugsnag.setContext('test-context');

    // Call setUser - should succeed
    await bugsnag.setUser(id: 'test-user-id', name: 'Test User');

    // Call addMetadata - should succeed
    await bugsnag.addMetadata('custom', {'key': 'value'});


    // Verify we can also use isStarted to guard calls defensively
    if (bugsnag.isStarted) {
      await bugsnag.leaveBreadcrumb(
        'Scenario completed',
        metadata: {'status': 'success'},
      );
    }

  }
}

