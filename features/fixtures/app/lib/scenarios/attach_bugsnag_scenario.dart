import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

class AttachBugsnagScenario extends Scenario {
  @override
  Future<void> run() async {
    await startNativeNotifier();
    await bugsnag.attach(
      runApp: () async {
        await Future.wait([
          bugsnag.setContext('flutter-test-context'),
          bugsnag.setUser(id: 'test-user-id', name: 'Old Man Tables'),
          bugsnag.addFeatureFlags(const [
            BugsnagFeatureFlag('demo-mode'),
            BugsnagFeatureFlag('sample-group', '123'),
          ]),
        ]);

        if (extraConfig?.contains("handled") == true) {
          await bugsnag.notify(
            Exception('Exception with attached info'),
            StackTrace.current,
          );
        } else {
          throw Exception('Exception with attached info');
        }
      },
    );
  }
}
