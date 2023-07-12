import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef MockMethodCall = dynamic Function(dynamic arguments);

class MockChannelClientController {
  static const channel = MethodChannel('com.bugsnag/client', JSONMethodCodec());

  Map<String, List<dynamic>> calls = {};
  Map<String, dynamic> results = {};

  MockChannelClientController() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, _handleClientMethodCall);
  }

  void reset([Map<String, dynamic>? newResults]) {
    calls = {};
    results = newResults ?? {};
  }

  List<dynamic> operator [](String methodName) => calls[methodName] ?? const [];

  Future<Object?> _handleClientMethodCall(MethodCall message) async {
    _storeMethodCall(message);

    final method = message.method;
    if (!results.containsKey(method)) {
      throw UnsupportedError('no result registered for $method');
    }

    final result = results[method];

    if (result is MockMethodCall) {
      return result(message.arguments);
    }

    return results[method];
  }

  void _storeMethodCall(MethodCall message) {
    final method = message.method;
    var callList = calls[method];
    if (callList == null) {
      callList = [];
      calls[method] = callList;
    }

    callList.add(message.arguments);
  }
}
