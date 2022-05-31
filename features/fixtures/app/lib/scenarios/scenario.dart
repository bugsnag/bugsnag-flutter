// ignore_for_file: avoid_print

import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/widgets.dart';

import '../channels.dart';

abstract class Scenario {
  late BugsnagEndpointConfiguration endpoints;

  String? extraConfig;

  Future<void> clearPersistentData() async {
    print('[MazeRunner] Clearing Persistent Data...');
    await MazeRunnerChannels.clearPersistentData();
  }

  Future<void> startNativeNotifier() =>
      MazeRunnerChannels.startBugsnag(endpoints);

  Future<void> startBugsnag() => bugsnag.start(endpoints: endpoints);

  Widget? createWidget() => null;

  Future<void> run();
}

void expect(dynamic actual, dynamic expected) {
  if (actual != expected) {
    throw AssertionError('Expected \'$expected\' but got \'$actual\'');
  }
}
