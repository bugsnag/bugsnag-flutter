import 'package:flutter/services.dart';

class MazeRunnerChannels {
  static const platform = MethodChannel('com.bugsnag.mazeRunner/platform');

  static Future<String> getCommand(String commandUrl) async {
    return await platform.invokeMethod("getCommand", {
      "commandUrl": commandUrl,
    }).then((value) => value ?? "");
  }

  static Future<void> runScenario(String scenarioName, {String? extraConfig}) {
    return platform.invokeMethod("runScenario", {
      'scenarioName': scenarioName,
      'extraConfig': extraConfig,
    });
  }

  /// Invoke Bugsnag.start on the native side as a temporary stand-in for
  /// a Flutter API
  @Deprecated("use bugsnag-flutter api once available")
  static Future<void> startBugsnag({
    required String notifyEndpoint,
    required String sessionEndpoint,
  }) {
    return platform.invokeMethod("startBugsnag", {
      "notifyEndpoint": notifyEndpoint,
      "sessionEndpoint": sessionEndpoint,
    });
  }
}
