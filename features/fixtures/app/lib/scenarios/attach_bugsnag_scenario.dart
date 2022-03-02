import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/core.dart';

class AttachBugsnagScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    await bugsnag.attach(
      context: 'flutter-test-context',
      user: const User(
        id: 'test-user-id',
        name: 'Old Man Tables',
      ),
      featureFlags: const [
        FeatureFlag('demo-mode'),
        FeatureFlag('sample-group', '123'),
      ],
    );

    throw Exception('Exception with attached info');
  }
}
