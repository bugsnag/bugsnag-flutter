import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import 'callbacks.dart';
import 'client.dart';
import 'config.dart';
import 'last_run_info.dart';
import 'model.dart';

/// JS interop bindings for the Bugsnag browser library.
/// Requires @bugsnag/browser to be loaded in the page.

@JS('Bugsnag')
external JSObject? get _bugsnagJS;

@JS('Bugsnag.start')
external JSObject _bugsnagStart(JSObject config);

@JS('Bugsnag.notify')
external void _bugsnagNotify(JSAny error, [JSObject? options]);

@JS('Bugsnag.setUser')
external void _bugsnagSetUser(JSString? id, JSString? email, JSString? name);

@JS('Bugsnag.resumeSession')
external JSBoolean _bugsnagResumeSession();

/// Web implementation of BugsnagClient using JS interop.
class WebClient extends BugsnagClient {
  FlutterExceptionHandler? _previousFlutterOnError;
  bool Function(Object, StackTrace)? _previousPlatformDispatcherOnError;
  final CallbackCollection<BugsnagEvent> _onErrorCallbacks = {};
  final bool _autoDetectErrors;

  WebClient(this._autoDetectErrors);

  @override
  void Function(dynamic error, StackTrace? stack) get errorHandler =>
      _notifyUnhandled;

  void _notifyUnhandled(dynamic error, StackTrace? stackTrace) {
    notify(error, stackTrace);
  }

  @override
  Future<void> setUser({String? id, String? email, String? name}) async {
    _checkBugsnagLoaded();
    _bugsnagSetUser(id?.toJS, email?.toJS, name?.toJS);
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
  Future<bool> resumeSession() async {
    _checkBugsnagLoaded();
    return _bugsnagResumeSession().toDart;
  }

  @override
  Future<void> markLaunchCompleted() => throw UnimplementedError(
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
    print('BUGSNAG: notify($error)');
  }

  @override
  void addOnError(BugsnagOnErrorCallback onError) {
    _onErrorCallbacks.add(onError);
  }

  @override
  void removeOnError(BugsnagOnErrorCallback onError) {
    _onErrorCallbacks.remove(onError);
  }

  void _onFlutterError(FlutterErrorDetails details) {
    print('BUGSNAG: FlutterError.onError: ${details.exception}');
  }

  bool _onDispatcherError(Object exception, StackTrace stack) {
    print('BUGSNAG: PlatformDispatcher.onError: $exception');
    return false; // allow default error handling to continue
  }

  @override
  Future<String?> setGroupingDiscriminator(String? value) =>
      throw UnimplementedError(
          'setGroupingDiscriminator is not yet supported on web');

  @override
  Future<String?> getGroupingDiscriminator() => throw UnimplementedError(
      'getGroupingDiscriminator is not yet supported on web');

  @override
  networkInstrumentation(data) {}

  void _checkBugsnagLoaded() {
    if (_bugsnagJS == null) {
      throw Exception(
        'Bugsnag is not loaded. Please add the @bugsnag/js script to your web/index.html.',
      );
    }
  }
}

/// Create bugsnag-js configuration from Bugsnag Flutter configuration.
JSObject _createWebConfig({
  required String apiKey,
  String? appVersion,
  String? releaseStage,
  Set<String>? enabledReleaseStages,
  BugsnagProjectPackages? projectPackages,
  bool collectUserIp = true,
}) {
  final config = <String, Object?>{
    'apiKey': apiKey,
    if (appVersion != null) 'appVersion': appVersion,
    if (releaseStage != null) 'releaseStage': releaseStage,
    if (enabledReleaseStages != null)
      'enabledReleaseStages': enabledReleaseStages.toList(),
    'collectUserIp': collectUserIp,
  };

  return _mapToJSObject(config);
}

JSObject _mapToJSObject(Map<String, Object?> map) {
  final jsonString = jsonEncode(map);
  return _jsonParse(jsonString.toJS);
}

Map<String, Object> _jsObjectToMap(JSObject obj) {
  final jsonString = _jsonStringify(obj).toDart;
  return (jsonDecode(jsonString) as Map).cast<String, Object>();
}

@JS('Error')
external JSAny _jsCreateError(JSString message);

@JS('JSON.parse')
external JSObject _jsonParse(JSString json);

@JS('JSON.stringify')
external JSString _jsonStringify(JSAny? value);

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
  BugsnagEndpointConfiguration endpoints = BugsnagEndpointConfiguration.bugsnag,
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
  bool collectUserIp = true,
}) async {
  if (apiKey == null) {
    throw ArgumentError('apiKey is required for web platform');
  }

  final detectDartErrors =
      autoDetectErrors && enabledErrorTypes.unhandledDartExceptions;

  final jsConfig = _createWebConfig(
    apiKey: apiKey,
    appVersion: appVersion,
    releaseStage: releaseStage,
    enabledReleaseStages: enabledReleaseStages,
    projectPackages: projectPackages,
    collectUserIp: collectUserIp,
  );

  _bugsnagStart(jsConfig);

  final client = WebClient(detectDartErrors);

  if (detectDartErrors) {
    client._previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = client._onFlutterError;
    client._previousPlatformDispatcherOnError =
        PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = client._onDispatcherError;
  }

  for (final callback in onError) {
    client.addOnError(callback);
  }

  return client;
}

Future<BugsnagClient> platformAttach({
  List<BugsnagOnErrorCallback> onError = const [],
  required Map<String, dynamic> notifier,
}) async {
  throw UnsupportedError('attach() is not supported on web');
}
