// test/endpoints_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';

void main() {
  const MethodChannel chan =
  MethodChannel('com.bugsnag/client', JSONMethodCodec());

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

  // Helper to extract endpoints sent over the method-channel
  Future<Map<String, dynamic>> _captureEndpoints(
      Future<void> Function() startCall) async {
    late Map<String, dynamic> captured;
    chan.setMockMethodCallHandler((call) async {
      if (call.method == 'start') {
        captured = Map<String, dynamic>.from(call.arguments['endpoints']);
        // mimic native reply
        return {'config': {'enabledErrorTypes': {'dartErrors': true}}};
      }
    });
    await startCall();
    chan.setMockMethodCallHandler(null);
    return captured;
  }

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

    test('honours explicitly-supplied endpoints, even for Hub-key', () async {
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