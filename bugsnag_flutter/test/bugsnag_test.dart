import 'package:bugsnag_flutter/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bugsnag', () {
    const channel = MethodChannel('com.bugsnag/client', JSONMethodCodec());

    test('attach throws error on failure', () async {
      TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        return false;
      });

      try {
        await bugsnag.attach();
        fail('bugsnag.attach should have thrown an exception');
      } catch (e) {
        expect(e, isInstanceOf<Exception>());
      }
    });

    test('attach', () async {
      TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        expect(call.arguments['context'], equals('flutter-context'));

        Map<String, dynamic> user = call.arguments['user'];
        expect(
          user,
          equals(const {
            'id': 'user-id-123',
            'name': 'Jonny Tables',
          }),
        );

        expect(
          call.arguments['featureFlags'],
          equals(const [
            {'featureFlag': 'demo-mode'},
            {'featureFlag': 'sample-group', 'variant': 'a'},
          ]),
        );

        return true;
      });

      await bugsnag.attach(
        context: 'flutter-context',
        user: User(id: 'user-id-123', name: 'Jonny Tables'),
        featureFlags: [
          FeatureFlag('demo-mode'),
          FeatureFlag('sample-group', 'a'),
        ],
      );
    });
  });
}
