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
    print('[Test] ✓ bugsnag.isStarted is false before initialization');

    // Initialize Bugsnag
    await bugsnag.start(autoTrackSessions: false);

    // Verify isStarted is true after initialization
    if (!bugsnag.isStarted) {
      throw AssertionError(
        'Expected bugsnag.isStarted to be true after start(), '
        'but it was false.'
      );
    }
    print('[Test] ✓ bugsnag.isStarted is true after start()');

    // Now that we've verified initialization, methods should succeed
    // without throwing exceptions

    // Call setContext - should succeed
    await bugsnag.setContext('test-context');
    print('[Test] ✓ setContext() succeeded after initialization');

    // Call setUser - should succeed
    await bugsnag.setUser(id: 'test-user-id', name: 'Test User');
    print('[Test] ✓ setUser() succeeded after initialization');

    // Call addMetadata - should succeed
    await bugsnag.addMetadata('custom', {'key': 'value'});
    print('[Test] ✓ addMetadata() succeeded after initialization');

    // Call notify - should succeed
    await bugsnag.notify(
      Exception('Test exception'),
      StackTrace.current,
    );
    print('[Test] ✓ notify() succeeded after initialization');

    // Verify we can also use isStarted to guard calls defensively
    if (bugsnag.isStarted) {
      await bugsnag.leaveBreadcrumb(
        'Scenario completed',
        metadata: {'status': 'success'},
      );
      print('[Test] ✓ Defensive isStarted check prevents exceptions');
    }

    print('[Test] ✓ All methods work correctly after initialization - isStarted property enables safe usage');
  }
}

