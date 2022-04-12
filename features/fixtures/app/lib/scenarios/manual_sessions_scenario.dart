import 'package:bugsnag_flutter/bugsnag.dart';

import 'scenario.dart';

class ManualSessionsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      autoTrackSessions: false,
      endpoints: endpoints,
    );
    await bugsnag.notify(Exception('No session'), null);
    await bugsnag.startSession();
    await bugsnag.notify(Exception('Session started'), null);
    await bugsnag.pauseSession();
    await bugsnag.notify(Exception('Session paused'), null);
    final resumed = await bugsnag.resumeSession();
    expect(resumed, true);
    await bugsnag.notify(Exception('Session resumed'), null);
  }
}
