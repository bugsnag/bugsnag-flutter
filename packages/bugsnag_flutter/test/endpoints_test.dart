// test/endpoints_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

/// Captures the `endpoints` map sent over the method-channel when
/// `bugsnag.start()` is invoked.
Future<Map<String, dynamic>> _captureEndpoints(
    Future<void> Function() startCall) async {
  // Ensure bindings are initialised so we have a defaultBinaryMessenger
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;

  const MethodChannel chan =
  MethodChannel('com.bugsnag/client', JSONMethodCodec());

  late Map<String, dynamic> captured;

  // Modern mock handler: receives a MethodCall, returns a Dart object
  Future<Object?> handler(MethodCall call) async {
    if (call.method == 'start') {
      captured = Map<String, dynamic>.from(call.arguments['endpoints']);
      // Minimal “success” reply expected by the SDK
      return {
        'config': {'enabledErrorTypes': {'dartErrors': true}}
      };
    }
    return null;
  }

  // Register the handler
  messenger.setMockMethodCallHandler(chan, handler);

  // Run the code under test
  await startCall();

  // Clean up
  messenger.setMockMethodCallHandler(chan, null);
  return captured;
}

void main() {
  // ────────────────────────────────────────────────────────────
  // Test fixtures
  // ────────────────────────────────────────────────────────────
  const normalKey = 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d';
  const hubKey    = '00000c0ffeebabe0000deadbeef0000';

  const defaultNotify   = 'https://notify.bugsnag.com';
  const defaultSessions = 'https://sessions.bugsnag.com';

  const hubNotify   = 'https://notify.insighthub.smartbear.com';
  const hubSessions = 'https://sessions.insighthub.smartbear.com';

  const customNotify   = 'https://my.example.com/n';
  const customSessions = 'https://my.example.com/s';

  group('Endpoint selection', () {
    test('keeps Bugsnag defaults for a normal apiKey', () async {
      final ep = await _captureEndpoints(
              () => bugsnag.start(apiKey: normalKey));

      expect(ep['notify'],   defaultNotify);
      expect(ep['sessions'], defaultSessions);
    });

    test('automatically switches to InsightHub for Hub-key', () async {
      final ep = await _captureEndpoints(
              () => bugsnag.start(apiKey: hubKey));

      expect(ep['notify'],   hubNotify);
      expect(ep['sessions'], hubSessions);
    });

    test('honours explicit endpoints even with a Hub-key', () async {
      final ep = await _captureEndpoints(() => bugsnag.start(
        apiKey: hubKey,
        endpoints: const BugsnagEndpointConfiguration(
          customNotify,
          customSessions,
        ),
      ));

      expect(ep['notify'],   customNotify);
      expect(ep['sessions'], customSessions);
    });
  });
}