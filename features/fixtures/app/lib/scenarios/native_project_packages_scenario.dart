import 'package:MazeRunner/channels.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class NativeProjectPackagesScenario extends Scenario {
  @override
  Future<void> run() async {
    await MazeRunnerChannels.runScenario('NativeProjectPackagesScenario', arguments: {
      'notifyEndpoint': endpoints.notify,
      'sessionEndpoint': endpoints.sessions
    });

    await bugsnag.attach(
      runApp: () async {
        throw Exception('Keep calm and carry on');
      },
    );
  }
}
