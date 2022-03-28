import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag.dart';

class StartBugsnagScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      apiKey: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      appType: 'test',
      appVersion: '1.2.3',
      context: 'awesome',
      user: User(
        id: '123',
        name: 'From Config',
      ),
      redactedKeys: {'secret'},
      releaseStage: 'testing',
      enabledReleaseStages: {'testing'},
      enabledBreadcrumbTypes: {BreadcrumbType.error},
      endpoints: endpoints,
      featureFlags: [
        FeatureFlag('demo-mode'),
        FeatureFlag('sample-group', '123'),
      ],
      metadata: Metadata({
        'custom': {
          'foo': 'bar',
          'secret': 'should be hidden',
          'password': 'not redacted'
        }
      }),
      sendThreads: ThreadSendPolicy.never,
    );
    await bugsnag.notify(Exception('Exception with attached info'),
        stackTrace: StackTrace.current);
  }
}