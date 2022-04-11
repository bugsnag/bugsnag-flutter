import 'dart:async';

import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag.dart';

class FeatureFlagsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      endpoints: endpoints,
      featureFlags: const [
        FeatureFlag('1'),
        FeatureFlag('2', 'foo'),
        FeatureFlag('3'),
      ],
    );

    await bugsnag.clearFeatureFlags();

    await bugsnag.addFeatureFlags(const [
      FeatureFlag('one'),
      FeatureFlag('two', 'foo'),
      FeatureFlag('three'),
    ]);
    await bugsnag.addFeatureFlag('four');
    await bugsnag.addFeatureFlag('five', 'six');
    await bugsnag.clearFeatureFlag('one');
    await bugsnag.addFeatureFlag('two', 'bar');

    await bugsnag.notify(Exception('Feature flags'), callback: (event) {
      event.addFeatureFlag('callback', 'yes');
      return true;
    });
  }
}
