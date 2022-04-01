import 'package:bugsnag_flutter/bugsnag.dart';

import 'scenario.dart';

class ManualSessionsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      autoTrackSessions: false,
      endpoints: endpoints,
    );
    await bugsnag.notify(Exception('No session'));
    await bugsnag.startSession();
    await bugsnag.notify(Exception('Session started'));
    await bugsnag.pauseSession();
    await bugsnag.notify(Exception('Session paused'));
    final resumed = await bugsnag.resumeSession();
    expect(resumed, true);
    await bugsnag.notify(Exception('Session resumed'));
  }
}
