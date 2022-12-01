import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

class AttachBugsnagScenario extends Scenario {
  @override
  Future<void> run() async {
    await startNativeNotifier();

    final attachFuture = await doAttach();
    if (extraConfig?.contains("extra-attach") == true) {
      await doAttach();
    }
  }

  Future<void> doAttach() async {
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
            Exception('Handled exception with attached info'),
            StackTrace.current,
          );
        } else {
          throw Exception('Unhandled exception with attached info');
        }
      },
    );
  }
}
