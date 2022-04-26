import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bugsnag_flutter/src/error_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;

import 'callbacks.dart';
import 'config.dart';
import 'last_run_info.dart';
import 'model.dart';

final _notifier = {
  'name': 'Flutter Bugsnag Notifier',
  'url': 'https://github.com/bugsnag/bugsnag-flutter',
  'version': '0.0.1'
};

abstract class Client {
  /// An utility error handling function that will send reported errors to
  /// Bugsnag as unhandled. The [errorHandler] is suitable for use with
  /// common Dart error callbacks such as [runZonedGuarded] or [Future.onError].
  void Function(dynamic error, StackTrace? stack) get errorHandler;

  Future<void> setUser({String? id, String? email, String? name});

  Future<User> getUser();

  Future<void> setContext(String? context);

  Future<String?> getContext();

  Future<void> leaveBreadcrumb(
    String message, {
    MetadataSection? metadata,
    BreadcrumbType type = BreadcrumbType.manual,
  });

  Future<List<BugsnagBreadcrumb>> getBreadcrumbs();

  Future<void> addFeatureFlag(String name, [String? variant]);

  Future<void> addFeatureFlags(List<FeatureFlag> featureFlags);

  Future<void> clearFeatureFlag(String name);

  Future<void> clearFeatureFlags();

  Future<void> addMetadata(String section, Map<String, Object> metadata);

  Future<void> clearMetadata(String section, [String? key]);

  Future<Map<String, Object>?> getMetadata(String section);

  Future<void> startSession();

  Future<void> pauseSession();

  Future<bool> resumeSession();

  Future<void> markLaunchCompleted();

  Future<LastRunInfo?> getLastRunInfo();

  Future<void> notify(
    dynamic error,
    StackTrace? stackTrace, {
    OnErrorCallback? callback,
  });

  void addOnError(OnErrorCallback onError);

  void removeOnError(OnErrorCallback onError);
}

class DelegateClient implements Client {
  Client? _client;

  Client get client {
    final localClient = _client;
    if (localClient == null) {
      throw Exception(
          'You must start or attach bugsnag before calling any other methods');
    }

    return localClient;
  }

  set client(Client client) {
    _client = client;
  }

  @override
  void Function(dynamic error, StackTrace? stack) get errorHandler =>
      client.errorHandler;

  @override
  Future<User> getUser() => client.getUser();

  @override
  Future<void> setUser({String? id, String? email, String? name}) =>
      client.setUser(id: id, email: email, name: name);

  @override
  Future<void> setContext(String? context) => client.setContext(context);

  @override
  Future<String?> getContext() => client.getContext();

  @override
  Future<void> leaveBreadcrumb(
    String message, {
    MetadataSection? metadata,
    BreadcrumbType type = BreadcrumbType.manual,
  }) =>
      client.leaveBreadcrumb(message, metadata: metadata, type: type);

  @override
  Future<List<BugsnagBreadcrumb>> getBreadcrumbs() => client.getBreadcrumbs();

  @override
  Future<void> addFeatureFlag(String name, [String? variant]) =>
      client.addFeatureFlag(name, variant);

  @override
  Future<void> addFeatureFlags(List<FeatureFlag> featureFlags) =>
      client.addFeatureFlags(featureFlags);

  @override
  Future<void> clearFeatureFlag(String name) => client.clearFeatureFlag(name);

  @override
  Future<void> clearFeatureFlags() => client.clearFeatureFlags();

  @override
  Future<void> addMetadata(String section, Map<String, Object> metadata) =>
      client.addMetadata(section, metadata);

  @override
  Future<void> clearMetadata(String section, [String? key]) =>
      client.clearMetadata(section, key);

  @override
  Future<MetadataSection?> getMetadata(String section) =>
      client.getMetadata(section);

  @override
  Future<void> startSession() => client.startSession();

  @override
  Future<void> pauseSession() => client.pauseSession();

  @override
  Future<bool> resumeSession() => client.resumeSession();

  @override
  Future<void> markLaunchCompleted() => client.markLaunchCompleted();

  @override
  Future<LastRunInfo?> getLastRunInfo() => client.getLastRunInfo();

  @override
  Future<void> notify(
    dynamic error,
    StackTrace? stackTrace, {
    OnErrorCallback? callback,
  }) =>
      client.notify(error, stackTrace, callback: callback);

  @override
  void addOnError(OnErrorCallback onError) => client.addOnError(onError);

  @override
  void removeOnError(OnErrorCallback onError) => client.removeOnError(onError);
}

class ChannelClient implements Client {
  FlutterExceptionHandler? _previousFlutterOnError;

  ChannelClient(bool autoDetectErrors) {
    if (autoDetectErrors) {
      // as ChannelClient is the only implementation that can run within the
      // same Isolate as Flutter, we install the FlutterError handler here
      _previousFlutterOnError = FlutterError.onError;
      FlutterError.onError = _onFlutterError;
    }
  }

  static const MethodChannel _channel =
      MethodChannel('com.bugsnag/client', JSONMethodCodec());

  final CallbackCollection<BugsnagEvent> _onErrorCallbacks = {};

  @override
  void Function(dynamic error, StackTrace? stack) get errorHandler =>
      _notifyUnhandled;

  @override
  Future<User> getUser() async =>
      User.fromJson(await _channel.invokeMethod('getUser'));

  @override
  Future<void> setUser({String? id, String? email, String? name}) =>
      _channel.invokeMethod(
        'setUser',
        User(id: id, email: email, name: name),
      );

  @override
  Future<void> setContext(String? context) =>
      _channel.invokeMethod('setContext', {'context': context});

  @override
  Future<String?> getContext() => _channel.invokeMethod('getContext');

  @override
  Future<void> leaveBreadcrumb(
    String message, {
    MetadataSection? metadata,
    BreadcrumbType type = BreadcrumbType.manual,
  }) async {
    final crumb = BugsnagBreadcrumb(message, type: type, metadata: metadata);
    await _channel.invokeMethod('leaveBreadcrumb', crumb);
  }

  @override
  Future<List<BugsnagBreadcrumb>> getBreadcrumbs() async =>
      List.from((await _channel.invokeMethod('getBreadcrumbs') as List)
          .map((e) => BugsnagBreadcrumb.fromJson(e)));

  @override
  Future<void> addFeatureFlag(String name, [String? variant]) =>
      _channel.invokeMethod('addFeatureFlags', [FeatureFlag(name, variant)]);

  @override
  Future<void> addFeatureFlags(List<FeatureFlag> featureFlags) =>
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
  Future<LastRunInfo?> getLastRunInfo() async {
    final json = await _channel.invokeMethod('getLastRunInfo');
    return (json == null) ? null : LastRunInfo.fromJson(json);
  }

  @override
  void addOnError(OnErrorCallback onError) {
    _onErrorCallbacks.add(onError);
  }

  @override
  void removeOnError(OnErrorCallback onError) {
    _onErrorCallbacks.remove(onError);
  }

  void _onFlutterError(FlutterErrorDetails details) {
    _notifyInternal(details.exception, true, details, details.stack, null);
    _previousFlutterOnError?.call(details);
  }

  Future<void> _notifyInternal(
    dynamic error,
    bool unhandled,
    FlutterErrorDetails? details,
    StackTrace? stackTrace,
    OnErrorCallback? callback,
  ) async {
    final errorPayload = ErrorFactory.instance.createError(error, stackTrace);
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
    OnErrorCallback? callback,
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
    final buildID = error.stacktrace.first.codeIdentifier;
    final errorInfo = details?.informationCollector?.call() ?? [];
    final errorContext = details?.context?.toDescription();
    final errorLibrary = details?.library;
    final lifecycleState = SchedulerBinding.instance?.lifecycleState.toString();
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
    final eventJson = await _channel.invokeMethod(
      'createEvent',
      {
        'error': error,
        'flutterMetadata': metadata,
        'unhandled': unhandled,
        'deliver': deliver
      },
    );

    if (eventJson != null) {
      return BugsnagEvent.fromJson(eventJson);
    }

    return null;
  }

  Future<void> _deliverEvent(BugsnagEvent event) =>
      _channel.invokeMethod('deliverEvent', event);
}

class Bugsnag extends Client with DelegateClient {
  /// Attach Bugsnag to an already initialised native notifier, optionally
  /// adding to its existing configuration. Use [start] if your application
  /// is entirely built in Flutter.
  ///
  /// Typical hybrid Flutter applications with Bugsnag will start with
  /// ```dart
  /// Future<void> main() => Bugsnag.attach(
  ///   runApp: () => runApp(MyApplication()),
  ///   // other configuration here
  /// );
  /// ```
  ///
  /// Use this method to initialize Flutter when developing a Hybrid app,
  /// where Bugsnag is being started by the native part of the app. For more
  /// information on starting Bugsnag natively, see our platform guides for:
  ///
  /// * Android: <https://docs.bugsnag.com/platforms/android/>
  /// * iOS: <https://docs.bugsnag.com/platforms/ios/>
  ///
  /// See also:
  ///
  /// * [start]
  /// * [setUser]
  /// * [setContext]
  /// * [addFeatureFlags]
  /// * [addOnError]
  Future<void> attach({
    FutureOr<void> Function()? runApp,
    bool autoDetectErrors = true,
    List<OnErrorCallback> onError = const [],
  }) async {
    // make sure we can use Channels before calling runApp
    _runWithErrorDetection(
      autoDetectErrors,
      () => WidgetsFlutterBinding.ensureInitialized(),
    );

    await ChannelClient._channel.invokeMethod('attach', {
      'notifier': _notifier,
    });

    final client = ChannelClient(autoDetectErrors);
    client._onErrorCallbacks.addAll(onError);
    this.client = client;

    _runWithErrorDetection(
      autoDetectErrors,
      () => runApp?.call(),
    );
  }

  /// Initialize the Bugsnag notifier with the configuration options specified.
  /// Use [attach] if you are building a Hybrid application where Bugsnag
  /// is initialised by the Native layer.
  ///
  /// [start] will pick up any native configuration options that are specified.
  ///
  /// Typical Flutter-only applications with Bugsnag will start with:
  /// ```dart
  /// Future<void> main() => Bugsnag.start(
  ///   apiKey: 'your-api-key',
  ///   runApp: () => runApp(MyApplication()),
  /// );
  /// ```
  ///
  /// See also:
  ///
  /// * [attach]
  /// * [setUser]
  /// * [setContext]
  /// * [addFeatureFlags]
  /// * [addOnError]
  Future<void> start({
    String? apiKey,
    FutureOr<void> Function()? runApp,
    User? user,
    bool persistUser = true,
    String? context,
    String? appType,
    String? appVersion,
    String? bundleVersion,
    String? releaseStage,
    EnabledErrorTypes enabledErrorTypes = EnabledErrorTypes.all,
    EndpointConfiguration endpoints = EndpointConfiguration.bugsnag,
    int maxBreadcrumbs = 50,
    int maxPersistedSessions = 128,
    int maxPersistedEvents = 32,
    bool autoTrackSessions = true,
    bool autoDetectErrors = true,
    ThreadSendPolicy sendThreads = ThreadSendPolicy.always,
    int launchDurationMillis = 5000,
    bool sendLaunchCrashesSynchronously = true,
    int appHangThresholdMillis = appHangThresholdFatalOnly,
    Set<String> redactedKeys = const {'password'},
    Set<String> discardClasses = const {},
    Set<String>? enabledReleaseStages,
    Set<EnabledBreadcrumbType>? enabledBreadcrumbTypes,
    Set<String>? projectPackages,
    Map<String, Map<String, Object>>? metadata,
    List<FeatureFlag>? featureFlags,
    List<OnErrorCallback> onError = const [],
    Directory? persistenceDirectory,
    int? versionCode,
  }) async {
    // guarding WidgetsFlutterBinding.ensureInitialized() catches
    // async errors within the Flutter app
    _runWithErrorDetection(
      autoDetectErrors,
      () => WidgetsFlutterBinding.ensureInitialized(),
    );

    // if required, we try to find the projectPackage here
    final defaultProjectPackage =
        (projectPackages == null) ? _findProjectPackage() : null;

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
      'autoTrackSessions': autoTrackSessions,
      'autoDetectErrors': autoDetectErrors,
      'sendThreads': sendThreads._toName(),
      'launchDurationMillis': launchDurationMillis,
      'sendLaunchCrashesSynchronously': sendLaunchCrashesSynchronously,
      'appHangThresholdMillis': appHangThresholdMillis,
      'redactedKeys': List<String>.from(redactedKeys),
      'discardClasses': List<String>.from(discardClasses),
      if (enabledReleaseStages != null)
        'enabledReleaseStages': enabledReleaseStages.toList(),
      'enabledBreadcrumbTypes':
          (enabledBreadcrumbTypes ?? EnabledBreadcrumbType.values)
              .map((e) => e._toName())
              .toList(),
      if (projectPackages != null)
        'projectPackages': List<String>.from(projectPackages),
      if (projectPackages == null && defaultProjectPackage != null)
        'defaultProjectPackage': defaultProjectPackage,
      if (metadata != null) 'metadata': BugsnagMetadata(metadata),
      'featureFlags': featureFlags,
      'notifier': _notifier,
      if (persistenceDirectory != null)
        'persistenceDirectory': persistenceDirectory.absolute.path,
      if (versionCode != null) 'versionCode': versionCode,
    });

    final client = ChannelClient(autoDetectErrors);
    client._onErrorCallbacks.addAll(onError);
    this.client = client;

    if (autoTrackSessions) {
      await resumeSession().onError((error, stackTrace) => true);
    }

    _runWithErrorDetection(autoDetectErrors, () => runApp?.call());
  }

  void _runWithErrorDetection(
    bool errorDetectionEnabled,
    FutureOr<void> Function() block,
  ) async {
    if (errorDetectionEnabled) {
      await runZonedGuarded(() async {
        await block();
      }, _reportZonedError);
    } else {
      await block();
    }
  }

  static const int appHangThresholdFatalOnly = 2147483647;

  /// Safely report an error that occurred within a guardedZone - if attached
  /// to a [Client] then use its [Client.errorHandler], otherwise push the error
  /// upwards using [Zone.handleUncaughtError]
  void _reportZonedError(dynamic error, StackTrace stackTrace) {
    if (_client != null) {
      errorHandler(error, stackTrace);
    } else {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  String? _findProjectPackage() {
    try {
      final frames = StackFrame.fromStackTrace(StackTrace.current);
      final lastBugsnag =
          frames.lastIndexWhere((f) => f.package.contains('bugsnag'));

      if (lastBugsnag != -1 && lastBugsnag < frames.length) {
        final package = frames[lastBugsnag + 1].package;
        return (package.isNotEmpty && package != 'null') ? package : null;
      }
    } catch (e) {
      // deliberately ignored, we return null
    }

    return null;
  }
}

final Bugsnag bugsnag = Bugsnag();

// The official EnumName extension was only added in 2.15
extension _EnumName on Enum {
  String _toName() => toString().split('.').last;
}
