import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/services.dart';

class MazeRunnerChannels {
  static const platform = MethodChannel('com.bugsnag.mazeRunner/platform');

  static Future<String> getCommand(String commandUrl) async {
    return await platform.invokeMethod("getCommand", {
      "commandUrl": commandUrl,
    }).then((value) => value ?? "");
  }

  static Future<void> clearPersistentData() {
    return platform.invokeMethod('clearPersistentData');
  }

  static Future<void> runScenario(String scenarioName,
          {Map<String, dynamic>? arguments}) async =>
      platform.invokeMethod('runScenario', {
        'scenarioName': scenarioName,
        ...?arguments,
      });

  static Future<void> startBugsnag(BugsnagEndpointConfiguration endpoints,
      {String? extraConfig}) {
    return platform.invokeMethod("startBugsnag", {
      'notifyEndpoint': endpoints.notify,
      'sessionEndpoint': endpoints.sessions,
      if (extraConfig != null) 'extraConfig': extraConfig,
    });
  }
}
