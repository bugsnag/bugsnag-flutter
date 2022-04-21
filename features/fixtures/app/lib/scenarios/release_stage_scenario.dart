import 'package:bugsnag_flutter/bugsnag.dart';

import 'scenario.dart';

class ReleaseStageScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      endpoints: endpoints,
      enabledReleaseStages: {'prod'},
      releaseStage: 'test',
    );

    try {
      throw Exception('this should be discarded');
    } catch (error, stackTrace) {
      await bugsnag.notify(error, stackTrace);
    }
  }
}
