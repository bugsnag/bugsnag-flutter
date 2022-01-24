import 'package:flutter/services.dart';

class MazeRunnerChannels {
  static const platform = MethodChannel('com.bugsnag.mazeRunner/platform');

  static Future<void> runScenario(
      {required String scenarioName, String? extraConfig}) {
    return platform.invokeMethod("runScenario", {
      'scenarioName': scenarioName,
      'extraConfig': extraConfig,
    });
  }

  /// Invoke Bugsnag.start on the native side as a temporary stand-in for
  /// a Flutter API
  @Deprecated("use bugsnag-flutter api once available")
  static Future<void> startBugsnag() {
    return platform.invokeMethod("startBugsnag");
  }
}
