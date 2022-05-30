import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class StartBugsnagScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      apiKey: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      appType: 'test',
      appVersion: '1.2.3',
      versionCode: 4321,
      context: 'awesome',
      user: BugsnagUser(
        id: '123',
        name: 'From Config',
      ),
      redactedKeys: {'secret'},
      releaseStage: 'testing',
      enabledReleaseStages: {'testing'},
      enabledBreadcrumbTypes: {BugsnagEnabledBreadcrumbType.error},
      endpoints: endpoints,
      featureFlags: const [
        BugsnagFeatureFlag('demo-mode'),
        BugsnagFeatureFlag('sample-group', '123'),
      ],
      metadata: const {
        'custom': {
          'foo': 'bar',
          'secret': 'should be hidden',
          'password': 'not redacted'
        }
      },
      sendThreads: BugsnagThreadSendPolicy.never,
      runApp: () async {
        await bugsnag.notify(
          Exception('Exception with attached info'),
          StackTrace.current,
        );
      },
    );
  }
}
