import 'callbacks.dart';
import 'client.dart';
import 'config.dart';
import 'model.dart';

Future<BugsnagClient> platformStart({
  String? apiKey,
  BugsnagUser? user,
  bool persistUser = true,
  String? context,
  String? appType,
  String? appVersion,
  String? bundleVersion,
  String? releaseStage,
  BugsnagEnabledErrorTypes enabledErrorTypes = BugsnagEnabledErrorTypes.all,
  BugsnagEndpointConfiguration endpoints =
      BugsnagEndpointConfiguration.bugsnag,
  int maxBreadcrumbs = 50,
  int maxPersistedSessions = 128,
  int maxPersistedEvents = 32,
  int maxStringValueLength = 10000,
  bool autoTrackSessions = true,
  bool autoDetectErrors = true,
  BugsnagThreadSendPolicy sendThreads = BugsnagThreadSendPolicy.always,
  int launchDurationMillis = 5000,
  bool sendLaunchCrashesSynchronously = true,
  int appHangThresholdMillis = Bugsnag.appHangThresholdFatalOnly,
  Set<RegExp>? redactedKeys,
  Set<RegExp> discardClasses = const {},
  Set<String>? enabledReleaseStages,
  Set<BugsnagEnabledBreadcrumbType>? enabledBreadcrumbTypes,
  BugsnagProjectPackages projectPackages =
      const BugsnagProjectPackages.withDefaults({}),
  Map<String, Map<String, Object>>? metadata,
  List<BugsnagFeatureFlag>? featureFlags,
  List<BugsnagOnErrorCallback> onError = const [],
  BugsnagTelemetryTypes telemetry = BugsnagTelemetryTypes.all,
  Object? persistenceDirectory,
  int? versionCode,
  required Map<String, dynamic> notifier,
}) async {
  throw UnsupportedError('start() is not supported on this platform');
}

Future<BugsnagClient> platformAttach({
  List<BugsnagOnErrorCallback> onError = const [],
  required Map<String, dynamic> notifier,
}) async {
  throw UnsupportedError('attach() is not supported on this platform');
}
