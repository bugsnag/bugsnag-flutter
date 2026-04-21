import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class CallBugsnagBeforeStartScenario extends Scenario {
  @override
  Future<void> run() async {
    // This scenario demonstrates the problem: calling Bugsnag methods before start()
    // Currently, this will throw an exception:
    // "You must start or attach bugsnag before calling any other methods"
    
    // Without isStarted, developers either have to:
    // 1. Wrap calls in try/catch
    // 2. Keep track of initialization state themselves
    // 3. Hope they call methods in the right order
    
    try {
      // Try to call setContext before starting - this should fail
      await bugsnag.setContext('test-context');
      
      throw AssertionError(
        'Expected an exception when calling setContext before start(), '
        'but the call succeeded. This indicates bugsnag was already initialized.'
      );
    } catch (e) {
      // Expected to fail with: "You must start or attach bugsnag before calling any other methods"
      if (e is AssertionError) {
        rethrow;
      }
      
      final errorMessage = e.toString();
      if (!errorMessage.contains('start or attach')) {
        throw AssertionError(
          'Expected exception message to contain "start or attach" '
          'but got: $errorMessage'
        );
      }
      
      print('[Test] ✓ Correctly threw exception when calling setContext before start()');
    }

    try {
      // Try to call setUser before starting - this should also fail
      await bugsnag.setUser(id: 'test-user-id', name: 'Test User');
      
      throw AssertionError(
        'Expected an exception when calling setUser before start(), '
        'but the call succeeded.'
      );
    } catch (e) {
      if (e is AssertionError) {
        rethrow;
      }
      
      final errorMessage = e.toString();
      if (!errorMessage.contains('start or attach')) {
        throw AssertionError(
          'Expected exception message to contain "start or attach" '
          'but got: $errorMessage'
        );
      }
      
      print('[Test] ✓ Correctly threw exception when calling setUser before start()');
    }

    try {
      // Try to call addMetadata before starting - this should also fail
      await bugsnag.addMetadata('custom', {'key': 'value'});
      
      throw AssertionError(
        'Expected an exception when calling addMetadata before start(), '
        'but the call succeeded.'
      );
    } catch (e) {
      if (e is AssertionError) {
        rethrow;
      }
      
      final errorMessage = e.toString();
      if (!errorMessage.contains('start or attach')) {
        throw AssertionError(
          'Expected exception message to contain "start or attach" '
          'but got: $errorMessage'
        );
      }
      
      print('[Test] ✓ Correctly threw exception when calling addMetadata before start()');
    }

    try {
      // Try to call notify before starting - this should also fail
      await bugsnag.notify(
        Exception('Test exception'),
        StackTrace.current,
      );
      
      throw AssertionError(
        'Expected an exception when calling notify before start(), '
        'but the call succeeded.'
      );
    } catch (e) {
      if (e is AssertionError) {
        rethrow;
      }
      
      final errorMessage = e.toString();
      if (!errorMessage.contains('start or attach')) {
        throw AssertionError(
          'Expected exception message to contain "start or attach" '
          'but got: $errorMessage'
        );
      }
      
      print('[Test] ✓ Correctly threw exception when calling notify before start()');
    }

    print('[Test] ✓ All failure cases verified - methods correctly throw exceptions before initialization');
  }
}

