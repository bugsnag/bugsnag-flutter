import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag.dart';

class AttachBugsnagScenario extends Scenario {
  @override
  Future<void> run() async {
    await startNativeNotifier();
    await bugsnag.attach(
      context: 'flutter-test-context',
      user: User(
        id: 'test-user-id',
        name: 'Old Man Tables',
      ),
      featureFlags: [
        FeatureFlag('demo-mode'),
        FeatureFlag('sample-group', '123'),
      ],
      runApp: () async {
        if (extraConfig?.contains("handled") == true) {
          await bugsnag.notify(
            Exception('Exception with attached info'),
            stackTrace: StackTrace.current,
          );
        } else {
          throw Exception('Exception with attached info');
        }
      },
    );
  }
}
