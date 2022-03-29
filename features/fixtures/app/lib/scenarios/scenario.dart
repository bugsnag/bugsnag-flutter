import 'package:bugsnag_flutter/bugsnag.dart';

import '../channels.dart';

abstract class Scenario {
  late EndpointConfiguration endpoints;

  String? extraConfig;

  Future<void> startNativeNotifier() =>
      MazeRunnerChannels.startBugsnag(endpoints);

  Future<void> startBugsnag() => bugsnag.start(endpoints: endpoints);

  Future<void> run();
}
