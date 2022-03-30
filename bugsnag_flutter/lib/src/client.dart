import 'dart:async';
import 'dart:io';

import 'package:bugsnag_flutter/src/error_factory.dart';
import 'package:flutter/services.dart';

import 'callbacks.dart';
import 'config.dart';
import 'model.dart';

abstract class Client {
  /// An utility error handling function that will send reported errors to
  /// Bugsnag as unhandled. The [errorHandler] is suitable for use with
  /// common Dart error callbacks such as [runZonedGuarded] or [Future.onError].
  void Function(dynamic error, StackTrace? stack) get errorHandler;

  Future<void> setUser({String? id, String? name, String? email});

  Future<User> getUser();

  Future<void> setContext(String? context);

  Future<String?> getContext();

  Future<void> leaveBreadcrumb(String message,
      {MetadataSection? metadata, BreadcrumbType type = BreadcrumbType.manual});

  Future<List<Breadcrumb>> getBreadcrumbs();

  Future<void> notify(
    dynamic error, {
    StackTrace? stackTrace,
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
  Future<void> setUser({String? id, String? name, String? email}) =>
      client.setUser(id: id, name: name, email: email);

  @override
  Future<void> setContext(String? context) => client.setContext(context);

  @override
  Future<String?> getContext() => client.getContext();

  @override
  Future<void> leaveBreadcrumb(String message,
          {MetadataSection? metadata,
          BreadcrumbType type = BreadcrumbType.manual}) =>
      client.leaveBreadcrumb(message, metadata: metadata, type: type);

  @override
  Future<List<Breadcrumb>> getBreadcrumbs() => client.getBreadcrumbs();

  @override
  Future<void> notify(
    dynamic error, {
    StackTrace? stackTrace,
    OnErrorCallback? callback,
  }) =>
      client.notify(error, stackTrace: stackTrace, callback: callback);

  @override
  void addOnError(OnErrorCallback onError) => client.addOnError(onError);

  @override
  void removeOnError(OnErrorCallback onError) => client.removeOnError(onError);
}

class ChannelClient implements Client {
  static const MethodChannel _channel =
      MethodChannel('com.bugsnag/client', JSONMethodCodec());

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
  Future<void> leaveBreadcrumb(String message,
          {MetadataSection? metadata,
          BreadcrumbType type = BreadcrumbType.manual}) =>
      _channel.invokeMethod('leaveBreadcrumb', {
        'message': message,
        'metaData': metadata ?? {},
        'type': type._toName()
      });

  @override
  Future<List<Breadcrumb>> getBreadcrumbs() async =>
      List.from((await _channel.invokeMethod('getBreadcrumbs') as List)
          .map((e) => Breadcrumb.fromJson(e)));

  @override
  void addOnError(OnErrorCallback onError) {
    _onErrorCallbacks.add(onError);
  }

  @override
  void removeOnError(OnErrorCallback onError) {
    _onErrorCallbacks.remove(onError);
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

    if (!await _onErrorCallbacks.dispatchEvent(event)) {
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
    final client = ChannelClient();
    bool attached = await ChannelClient._channel.invokeMethod('attach', {
      if (user != null) 'user': user,
      if (context != null) 'context': context,
      if (featureFlags != null) 'featureFlags': featureFlags,
    });

    if (!attached) {
      final platformStart =
          Platform.isAndroid ? 'Bugsnag.start()' : '[Bugsnag start]';
      final platformName = Platform.isAndroid ? 'Android' : 'iOS';

      throw Exception(
        'bugsnag.attach can only be called when the native layer has already been started, have you called $platformStart in your $platformName code?',
      );
    }

    client._onErrorCallbacks.addAll(onError);

    this.client = client;

    if (runApp != null) {
      await runZoned(runApp);
    }
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
    final client = ChannelClient();
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
    });
    client._onErrorCallbacks.addAll(onError);
    this.client = client;

    if (runApp != null) {
      await runZoned(runApp);
    }
  }
}

final Bugsnag bugsnag = Bugsnag();

// The official EnumName extension was only added in 2.15
extension _EnumName on Enum {
  String _toName() => toString().split('.').last;
}
