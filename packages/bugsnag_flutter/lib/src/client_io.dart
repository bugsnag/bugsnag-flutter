import 'dart:io';
import 'dart:ui';

import 'package:bugsnag_bridge/bugsnag_bridge.dart';
import 'package:bugsnag_flutter/src/error_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;

import 'callbacks.dart';
import 'client.dart';
import 'config.dart';
import 'enum_utils.dart';
import 'last_run_info.dart';
import 'model.dart';
import 'regexp_json.dart';

class ChannelClient extends BugsnagClient {
  FlutterExceptionHandler? _previousFlutterOnError;
  ErrorCallback? _previousPlatformDispatcherOnError;

  ChannelClient(bool autoDetectErrors) {
    if (autoDetectErrors) {
      // as ChannelClient is the only implementation that can run within the
      // same Isolate as Flutter, we install the FlutterError handler here
      _previousFlutterOnError = FlutterError.onError;
      FlutterError.onError = _onFlutterError;
      _previousPlatformDispatcherOnError = PlatformDispatcher.instance.onError;
      PlatformDispatcher.instance.onError = _onDispatcherError;
    }
  }

  static const MethodChannel _channel =
      MethodChannel('com.bugsnag/client', JSONMethodCodec());

  final CallbackCollection<BugsnagEvent> _onErrorCallbacks = {};

  final contextProvider = BugsnagContextProviderImpl();

  @override
  void Function(dynamic error, StackTrace? stack) get errorHandler =>
      _notifyUnhandled;

  @override
  Future<BugsnagUser> getUser() async =>
      BugsnagUser.fromJson(await _channel.invokeMethod('getUser'));

  @override
  Future<void> setUser({String? id, String? email, String? name}) =>
      _channel.invokeMethod(
        'setUser',
        BugsnagUser(id: id, email: email, name: name),
      );

  @override
  Future<void> setContext(String? context) =>
      _channel.invokeMethod('setContext', {'context': context});

  @override
  Future<String?> getContext() => _channel.invokeMethod('getContext');

  @override
  Future<String?> getGroupingDiscriminator() =>
      _channel.invokeMethod<String?>('getGroupingDiscriminator');

  @override
  Future<String?> setGroupingDiscriminator(String? value) =>
      _channel.invokeMethod<String?>(
        'setGroupingDiscriminator',
        {'value': value},
      );

  @override
  Future<void> leaveBreadcrumb(
    String message, {
    Map<String, Object>? metadata,
    BugsnagBreadcrumbType type = BugsnagBreadcrumbType.manual,
  }) async {
    final crumb = BugsnagBreadcrumb(message, type: type, metadata: metadata);
    await _channel.invokeMethod('leaveBreadcrumb', crumb);
  }

  @override
  Future<List<BugsnagBreadcrumb>> getBreadcrumbs() async =>
      List.from((await _channel.invokeMethod('getBreadcrumbs') as List)
          .map((e) => BugsnagBreadcrumb.fromJson(e)));

  @override
  Future<void> addFeatureFlag(String name, [String? variant]) => _channel
      .invokeMethod('addFeatureFlags', [BugsnagFeatureFlag(name, variant)]);

  @override
  Future<void> addFeatureFlags(List<BugsnagFeatureFlag> featureFlags) =>
      _channel.invokeMethod('addFeatureFlags', featureFlags);

  @override
  Future<void> clearFeatureFlag(String name) =>
      _channel.invokeMethod('clearFeatureFlag', {'name': name});

  @override
  Future<void> clearFeatureFlags() =>
      _channel.invokeMethod('clearFeatureFlags');

  @override
  Future<void> addMetadata(String section, Map<String, Object> metadata) =>
      _channel.invokeMethod('addMetadata', {
        'section': section,
        'metadata': BugsnagMetadata.sanitizedMap(metadata),
      });

  @override
  Future<void> clearMetadata(String section, [String? key]) =>
      _channel.invokeMethod('clearMetadata', {
        'section': section,
        if (key != null) 'key': key,
      });

  @override
  Future<Map<String, Object>?> getMetadata(String section) async {
    final metadata = await _channel.invokeMethod(
      'getMetadata',
      {'section': section},
    );

    return (metadata != null) ? Map.from(metadata).cast() : null;
  }

  @override
  Future<void> startSession() => _channel.invokeMethod('startSession');

  @override
  Future<void> pauseSession() => _channel.invokeMethod('pauseSession');

  @override
  Future<bool> resumeSession() async =>
      await _channel.invokeMethod('resumeSession') as bool;

  @override
  Future<void> markLaunchCompleted() =>
      _channel.invokeMethod('markLaunchCompleted');

  @override
  Future<BugsnagLastRunInfo?> getLastRunInfo() async {
    final json = await _channel.invokeMethod('getLastRunInfo');
    return (json == null) ? null : BugsnagLastRunInfo.fromJson(json);
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
    _notifyInternal(details.exception, true, details, details.stack, null);
    _previousFlutterOnError?.call(details);
  }

  bool _onDispatcherError(Object exception, StackTrace stack) {
    _notifyInternal(exception, true, null, stack, null);
    return _previousPlatformDispatcherOnError?.call(exception, stack) ?? false;
  }

  Future<void> _notifyInternal(
    dynamic error,
    bool unhandled,
    FlutterErrorDetails? details,
    StackTrace? stackTrace,
    BugsnagOnErrorCallback? callback,
  ) async {
    final errorPayload =
        BugsnagErrorFactory.instance.createError(error, stackTrace);
    final event = await _createEvent(
      errorPayload,
      details: details,
      unhandled: unhandled,
      deliver: _onErrorCallbacks.isEmpty && callback == null,
    );

    if (event == null) {
      return;
    }

    if (!await _onErrorCallbacks.dispatch(event)) {
      // callback rejected the payload - so we don't deliver it
      return;
    }

    if (callback != null && !await callback.invokeSafely(event)) {
      // callback rejected the payload - so we don't deliver it
      return;
    }

    await _deliverEvent(event);
  }

  @override
  Future<void> notify(
    dynamic error,
    StackTrace? stackTrace, {
    BugsnagOnErrorCallback? callback,
  }) {
    return _notifyInternal(error, false, null, stackTrace, callback);
  }

  void _notifyUnhandled(dynamic error, StackTrace? stackTrace) {
    _notifyInternal(error, true, null, stackTrace, null);
  }

  /// Create an Event by having it built by the native notifier,
  /// if [deliver] is `true` return `null` and schedule the `Event` for immediate
  /// delivery. If [deliver] is `false` then the `Event` is only constructed
  /// and returned to be processed by the Flutter notifier.
  Future<BugsnagEvent?> _createEvent(
    BugsnagError error, {
    FlutterErrorDetails? details,
    required bool unhandled,
    required bool deliver,
  }) async {
    final buildID = error.stacktrace.isNotEmpty
        ? error.stacktrace.first.codeIdentifier
        : null;
    final errorInfo = details?.informationCollector?.call() ?? [];
    final errorContext = details?.context?.toDescription();
    final errorLibrary = details?.library;
    // SchedulerBinding.instance is nullable in Flutter <3.0.0
    // ignore: unnecessary_cast
    final schedulerBinding = SchedulerBinding.instance as SchedulerBinding?;
    final lifecycleState = schedulerBinding?.lifecycleState.toString();
    final metadata = {
      if (buildID != null) 'buildID': buildID,
      if (errorContext != null) 'errorContext': errorContext,
      if (errorLibrary != null) 'errorLibrary': errorLibrary,
      if (errorInfo.isNotEmpty)
        'errorInformation':
            (StringBuffer()..writeAll(errorInfo, '\n')).toString(),
      'defaultRouteName': PlatformDispatcher.instance.defaultRouteName,
      'initialLifecycleState':
          PlatformDispatcher.instance.initialLifecycleState,
      if (lifecycleState != null) 'lifecycleState': lifecycleState,
    };
    final traceContext = contextProvider.getCurrentTraceContext();
    final correlation = traceContext != null
        ? {
            'spanId': traceContext.spanId,
            'traceId': traceContext.traceId,
          }
        : null;
    final eventJson = await _channel.invokeMethod(
      'createEvent',
      {
        'error': error,
        'flutterMetadata': metadata,
        'unhandled': unhandled,
        'deliver': deliver,
        if (correlation != null) 'correlation': correlation,
      },
    );

    if (eventJson != null) {
      final event = BugsnagEvent.fromJson(eventJson);

      // Inherit the global value only if the event doesn't already have one
      event.groupingDiscriminator ??= await getGroupingDiscriminator();

      return event; // callbacks run after this, and can still override
    }

    return null;
  }

  Future<void> _deliverEvent(BugsnagEvent event) =>
      _channel.invokeMethod('deliverEvent', event);

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
  final detectDartErrors =
      autoDetectErrors && enabledErrorTypes.unhandledDartExceptions;

  // make sure we can use Channels
  WidgetsFlutterBinding.ensureInitialized();

  await ChannelClient._channel.invokeMethod('start', <String, dynamic>{
    if (apiKey != null) 'apiKey': apiKey,
    if (user != null) 'user': user,
    'persistUser': persistUser,
    if (context != null) 'context': context,
    if (appType != null) 'appType': appType,
    if (appVersion != null) 'appVersion': appVersion,
    if (bundleVersion != null) 'bundleVersion': bundleVersion,
    if (releaseStage != null) 'releaseStage': releaseStage,
    'enabledErrorTypes': enabledErrorTypes,
    'endpoints': endpoints,
    'maxBreadcrumbs': maxBreadcrumbs,
    'maxPersistedSessions': maxPersistedSessions,
    'maxPersistedEvents': maxPersistedEvents,
    'maxStringValueLength': maxStringValueLength,
    'autoTrackSessions': autoTrackSessions,
    'autoDetectErrors': autoDetectErrors,
    'sendThreads': sendThreads.toName(),
    'launchDurationMillis': launchDurationMillis,
    'sendLaunchCrashesSynchronously': sendLaunchCrashesSynchronously,
    'appHangThresholdMillis': appHangThresholdMillis,
    'redactedKeys': List<dynamic>.from(redactedKeys?.map((e) => e.toJson()) ??
        {RegExp('password').toJson()}),
    'discardClasses':
        List<dynamic>.from(discardClasses.map((e) => e.toJson())),
    if (enabledReleaseStages != null)
      'enabledReleaseStages': enabledReleaseStages.toList(),
    'enabledBreadcrumbTypes':
        (enabledBreadcrumbTypes ?? BugsnagEnabledBreadcrumbType.values)
            .map((e) => e.toName())
            .toList(),
    'projectPackages': projectPackages,
    if (metadata != null) 'metadata': BugsnagMetadata(metadata),
    'featureFlags': featureFlags,
    'notifier': notifier,
    'telemetry': telemetry,
    if (persistenceDirectory != null)
      'persistenceDirectory': (persistenceDirectory as Directory).absolute.path,
    if (versionCode != null) 'versionCode': versionCode,
  });

  final client = ChannelClient(detectDartErrors);
  client._onErrorCallbacks.addAll(onError);
  return client;
}

Future<BugsnagClient> platformAttach({
  List<BugsnagOnErrorCallback> onError = const [],
  required Map<String, dynamic> notifier,
}) async {
  // make sure we can use Channels
  WidgetsFlutterBinding.ensureInitialized();

  final result = await ChannelClient._channel.invokeMethod('attach', {
    'notifier': notifier,
  });

  final autoDetectErrors =
      result['config']['enabledErrorTypes']['dartErrors'] as bool;

  final client = ChannelClient(autoDetectErrors);
  client._onErrorCallbacks.addAll(onError);
  return client;
}
