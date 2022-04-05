import 'dart:async';

import 'package:bugsnag_flutter/src/error_factory.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> setUser({String? id, String? name, String? email});

  Future<User> getUser();

  Future<void> setContext(String? context);

  Future<String?> getContext();

  Future<void> leaveBreadcrumb(
    String message, {
    MetadataSection? metadata,
    BreadcrumbType type = BreadcrumbType.manual,
  });

  Future<List<Breadcrumb>> getBreadcrumbs();

  Future<void> addFeatureFlag(String name, [String? variant]);

  Future<void> addFeatureFlags(List<FeatureFlag> featureFlags);

  Future<void> clearFeatureFlag(String name);

  Future<void> clearFeatureFlags();

  Future<void> startSession();

  Future<void> pauseSession();

  Future<bool> resumeSession();

  Future<void> markLaunchComplete();

  Future<LastRunInfo?> getLastRunInfo();

  Future<void> notify(
    dynamic error, {
    StackTrace? stackTrace,
    OnErrorCallback? callback,
  });

  void addOnBreadcrumb(OnBreadcrumbCallback onBreadcrumb);

  void removeOnBreadcrumb(OnBreadcrumbCallback onBreadcrumb);

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
  Future<void> setUser({String? id, String? name, String? email}) =>
      client.setUser(id: id, name: name, email: email);

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
  Future<List<Breadcrumb>> getBreadcrumbs() => client.getBreadcrumbs();

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
  Future<void> startSession() => client.startSession();

  @override
  Future<void> pauseSession() => client.pauseSession();

  @override
  Future<bool> resumeSession() => client.resumeSession();

  @override
  Future<void> markLaunchComplete() => client.markLaunchComplete();

  @override
  Future<LastRunInfo?> getLastRunInfo() => client.getLastRunInfo();

  @override
  Future<void> notify(
    dynamic error, {
    StackTrace? stackTrace,
    OnErrorCallback? callback,
  }) =>
      client.notify(error, stackTrace: stackTrace, callback: callback);

  @override
  void addOnBreadcrumb(OnBreadcrumbCallback onBreadcrumb) =>
      client.addOnBreadcrumb(onBreadcrumb);

  @override
  void removeOnBreadcrumb(OnBreadcrumbCallback onBreadcrumb) =>
      client.removeOnBreadcrumb(onBreadcrumb);

  @override
  void addOnError(OnErrorCallback onError) => client.addOnError(onError);

  @override
  void removeOnError(OnErrorCallback onError) => client.removeOnError(onError);
}

class ChannelClient implements Client {
  FlutterExceptionHandler? _previousFlutterOnError;

  ChannelClient() {
    _previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = _onFlutterError;
  }

  static const MethodChannel _channel =
      MethodChannel('com.bugsnag/client', JSONMethodCodec());

  final CallbackCollection<Breadcrumb> _onBreadcrumbCallbacks = {};
  final CallbackCollection<Event> _onErrorCallbacks = {};

  @override
  void Function(dynamic error, StackTrace? stack) get errorHandler =>
      _notifyUnhandled;

  @override
  Future<User> getUser() async =>
      User.fromJson(await _channel.invokeMethod('getUser'));

  @override
  Future<void> setUser({String? id, String? name, String? email}) =>
      _channel.invokeMethod(
        'setUser',
        User(id: id, name: name, email: email),
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
    final crumb = Breadcrumb(message, type: type, metadata: metadata);
    if (await _onBreadcrumbCallbacks.dispatch(crumb)) {
      await _channel.invokeMethod('leaveBreadcrumb', crumb);
    }
  }

  @override
  Future<List<Breadcrumb>> getBreadcrumbs() async =>
      List.from((await _channel.invokeMethod('getBreadcrumbs') as List)
          .map((e) => Breadcrumb.fromJson(e)));

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
  Future<void> startSession() => _channel.invokeMethod('startSession');

  @override
  Future<void> pauseSession() => _channel.invokeMethod('pauseSession');

  @override
  Future<bool> resumeSession() async =>
      await _channel.invokeMethod('resumeSession') as bool;

  @override
  Future<void> markLaunchComplete() =>
      _channel.invokeMethod('markLaunchComplete');

  @override
  Future<LastRunInfo?> getLastRunInfo() async {
    final json = await _channel.invokeMethod('getLastRunInfo');
    return (json == null) ? null : LastRunInfo.fromJson(json);
  }

  @override
  void addOnBreadcrumb(OnBreadcrumbCallback onBreadcrumb) =>
      _onBreadcrumbCallbacks.add(onBreadcrumb);

  @override
  void removeOnBreadcrumb(OnBreadcrumbCallback onBreadcrumb) =>
      _onBreadcrumbCallbacks.remove(onBreadcrumb);

  @override
  void addOnError(OnErrorCallback onError) {
    _onErrorCallbacks.add(onError);
  }

  @override
  void removeOnError(OnErrorCallback onError) {
    _onErrorCallbacks.remove(onError);
  }

  void _onFlutterError(FlutterErrorDetails details) {
    _notifyInternal(details.exception, true, details.stack, null);
    _previousFlutterOnError?.call(details);
  }

  Future<void> _notifyInternal(
    dynamic error,
    bool unhandled,
    StackTrace? stackTrace,
    OnErrorCallback? callback,
  ) async {
    final errorPayload = ErrorFactory.instance.createError(error, stackTrace);
    final event = await _createEvent(
      errorPayload,
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
    dynamic error, {
    StackTrace? stackTrace,
    OnErrorCallback? callback,
  }) {
    return _notifyInternal(error, false, stackTrace, callback);
  }

  void _notifyUnhandled(dynamic error, StackTrace? stackTrace) async {
    _notifyInternal(error, true, stackTrace, null);
  }

  /// Create an Event by having it built by the native notifier,
  /// if [deliver] is `true` return `null` and schedule the `Event` for immediate
  /// delivery. If [deliver] is `false` then the `Event` is only constructed
  /// and returned to be processed by the Flutter notifier.
  Future<Event?> _createEvent(
    Error error, {
    required bool unhandled,
    required bool deliver,
  }) async {
    final eventJson = await _channel.invokeMethod(
      'createEvent',
      {'error': error, 'unhandled': unhandled, 'deliver': deliver},
    );

    if (eventJson != null) {
      return Event.fromJson(eventJson);
    }

    return null;
  }

  Future<void> _deliverEvent(Event event) =>
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
    User? user,
    String? context,
    List<FeatureFlag>? featureFlags,
    List<OnSessionCallback> onSession = const [],
    List<OnBreadcrumbCallback> onBreadcrumb = const [],
    List<OnErrorCallback> onError = const [],
  }) async {
    await runZonedGuarded(() async {
      // make sure we can use Channels before calling runApp
      WidgetsFlutterBinding.ensureInitialized();
    }, _reportZonedError);

    await ChannelClient._channel.invokeMethod('attach', {
      if (user != null) 'user': user,
      if (context != null) 'context': context,
      if (featureFlags != null) 'featureFlags': featureFlags,
      'notifier': _notifier,
    });

    final client = ChannelClient();
    client._onErrorCallbacks.addAll(onError);
    this.client = client;

    runZonedGuarded(() async {
      await runApp?.call();
    }, _reportZonedError);
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
    ThreadSendPolicy sendThreads = ThreadSendPolicy.always,
    int launchDurationMillis = 5000,
    Set<String> redactedKeys = const {'password'},
    Set<String>? enabledReleaseStages,
    Set<BreadcrumbType> enabledBreadcrumbTypes = const {
      BreadcrumbType.navigation,
      BreadcrumbType.request,
      BreadcrumbType.log,
      BreadcrumbType.user,
      BreadcrumbType.state,
      BreadcrumbType.error,
      BreadcrumbType.manual
    },
    Metadata? metadata,
    List<FeatureFlag>? featureFlags,
    List<OnSessionCallback> onSession = const [],
    List<OnBreadcrumbCallback> onBreadcrumb = const [],
    List<OnErrorCallback> onError = const [],
  }) async {
    // guarding WidgetsFlutterBinding.ensureInitialized() catches
    // async errors within the Flutter app
    await runZonedGuarded(() async {
      // make sure we can use Channels before calling runApp
      WidgetsFlutterBinding.ensureInitialized();
    }, _reportZonedError);

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
      'sendThreads': sendThreads._toName(),
      'launchDurationMillis': launchDurationMillis,
      'redactedKeys': List<String>.from(redactedKeys),
      if (enabledReleaseStages != null)
        'enabledReleaseStages': List<String>.from(enabledReleaseStages),
      'enabledBreadcrumbTypes': List<String>.from(
        enabledBreadcrumbTypes.map((e) => e._toName()),
      ),
      'metadata': metadata,
      'featureFlags': featureFlags,
      'notifier': _notifier,
    });

    final client = ChannelClient();
    client._onErrorCallbacks.addAll(onError);
    this.client = client;

    runZonedGuarded(() async {
      await runApp?.call();
    }, _reportZonedError);
  }

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
}

final Bugsnag bugsnag = Bugsnag();

// The official EnumName extension was only added in 2.15
extension _EnumName on Enum {
  String _toName() => toString().split('.').last;
}
