import 'callbacks.dart';
import 'client.dart';
import 'config.dart';
import 'last_run_info.dart';
import 'model.dart';

class WebClient extends BugsnagClient {
  final CallbackCollection<BugsnagEvent> _onErrorCallbacks = {};

  @override
  void Function(dynamic error, StackTrace? stack) get errorHandler =>
      _notifyUnhandled;

  void _notifyUnhandled(dynamic error, StackTrace? stackTrace) {
    notify(error, stackTrace);
  }

  @override
  Future<void> setUser({String? id, String? email, String? name}) async {
    print('setUser(id: $id, email: $email, name: $name)');
  }

  @override
  Future<BugsnagUser> getUser() =>
      throw UnimplementedError('getUser is not yet supported on web');

  @override
  Future<void> setContext(String? context) =>
      throw UnimplementedError('setContext is not yet supported on web');

  @override
  Future<String?> getContext() =>
      throw UnimplementedError('getContext is not yet supported on web');

  @override
  Future<void> leaveBreadcrumb(
    String message, {
    Map<String, Object>? metadata,
    BugsnagBreadcrumbType type = BugsnagBreadcrumbType.manual,
  }) =>
      throw UnimplementedError('leaveBreadcrumb is not yet supported on web');

  @override
  Future<List<BugsnagBreadcrumb>> getBreadcrumbs() =>
      throw UnimplementedError('getBreadcrumbs is not yet supported on web');

  @override
  Future<void> addFeatureFlag(String name, [String? variant]) =>
      throw UnimplementedError('addFeatureFlag is not yet supported on web');

  @override
  Future<void> addFeatureFlags(List<BugsnagFeatureFlag> featureFlags) =>
      throw UnimplementedError('addFeatureFlags is not yet supported on web');

  @override
  Future<void> clearFeatureFlag(String name) =>
      throw UnimplementedError('clearFeatureFlag is not yet supported on web');

  @override
  Future<void> clearFeatureFlags() =>
      throw UnimplementedError('clearFeatureFlags is not yet supported on web');

  @override
  Future<void> addMetadata(String section, Map<String, Object> metadata) =>
      throw UnimplementedError('addMetadata is not yet supported on web');

  @override
  Future<void> clearMetadata(String section, [String? key]) =>
      throw UnimplementedError('clearMetadata is not yet supported on web');

  @override
  Future<Map<String, Object>?> getMetadata(String section) =>
      throw UnimplementedError('getMetadata is not yet supported on web');

  @override
  Future<void> startSession() =>
      throw UnimplementedError('startSession is not yet supported on web');

  @override
  Future<void> pauseSession() =>
      throw UnimplementedError('pauseSession is not yet supported on web');

  @override
  Future<bool> resumeSession() =>
      throw UnimplementedError('resumeSession is not yet supported on web');

  @override
  Future<void> markLaunchCompleted() =>
      throw UnimplementedError(
          'markLaunchCompleted is not yet supported on web');

  @override
  Future<BugsnagLastRunInfo?> getLastRunInfo() =>
      throw UnimplementedError('getLastRunInfo is not yet supported on web');

  @override
  Future<void> notify(
    dynamic error,
    StackTrace? stackTrace, {
    BugsnagOnErrorCallback? callback,
  }) async {
    print('notify($error)');
  }

  @override
  void addOnError(BugsnagOnErrorCallback onError) {
    _onErrorCallbacks.add(onError);
  }

  @override
  void removeOnError(BugsnagOnErrorCallback onError) {
    _onErrorCallbacks.remove(onError);
  }

  @override
  Future<String?> setGroupingDiscriminator(String? value) =>
      throw UnimplementedError(
          'setGroupingDiscriminator is not yet supported on web');

  @override
  Future<String?> getGroupingDiscriminator() =>
      throw UnimplementedError(
          'getGroupingDiscriminator is not yet supported on web');

  @override
  networkInstrumentation(data) {}
}

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
  print('start()');
  return WebClient();
}

Future<BugsnagClient> platformAttach({
  List<BugsnagOnErrorCallback> onError = const [],
  required Map<String, dynamic> notifier,
}) async {
  throw UnsupportedError('attach() is not supported on web');
}
