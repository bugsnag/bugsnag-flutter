import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'model.dart';

abstract class Client {
  Future<void> setUser({String? id, String? name, String? email});

  Future<User> getUser();

  Future<void> setContext(String? context);

  Future<String?> getContext();
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
  Future<User> getUser() => client.getUser();

  @override
  Future<void> setUser({String? id, String? name, String? email}) =>
      client.setUser(id: id, name: name, email: email);

  @override
  Future<void> setContext(String? context) => client.setContext(context);

  @override
  Future<String?> getContext() => client.getContext();
}

class ChannelClient implements Client {
  static const MethodChannel _channel =
      MethodChannel('com.bugsnag/client', JSONMethodCodec());

  const ChannelClient();

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
}

class Bugsnag extends Client with DelegateClient {
  /// Attach Bugsnag to an already initialised native notifier, optionally
  /// adding to its existing configuration. Use [start] if your application
  /// is entirely built in Flutter.
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
  Future<void> attach({
    User? user,
    String? context,
    List<FeatureFlag>? featureFlags,
    List<FutureOr<bool> Function(Session)> onSession = const [],
    List<FutureOr<bool> Function(Breadcrumb)> onBreadcrumb = const [],
  }) async {
    const client = ChannelClient();
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

    this.client = client;
  }
}

final Bugsnag bugsnag = Bugsnag();