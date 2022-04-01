import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_channel.dart';

void main() {
  final channel = MockChannelClientController();

  group('Bugsnag', () {
    setUp(() {
      channel.reset();
    });

    test('attach throws error on failure', () async {
      channel.results['attach'] = false;
      try {
        await bugsnag.attach();
        fail('bugsnag.attach should have thrown an exception');
      } catch (e) {
        expect(e, isInstanceOf<Exception>());
      }
    });

    test('attach', () async {
      channel.results['attach'] = true;

      await bugsnag.attach(
        context: 'flutter-context',
        user: User(id: 'user-id-123', name: 'Bobby Tables'),
        featureFlags: [
          FeatureFlag('demo-mode'),
          FeatureFlag('sample-group', 'a'),
        ],
      );

      expect(channel['attach'], hasLength(1));

      dynamic attach = channel['attach'][0];
      expect(attach['user']['id'], equals('user-id-123'));
      expect(attach['user']['name'], equals('Bobby Tables'));

      expect(attach['featureFlags'], hasLength(2));
      expect(
        attach['featureFlags'],
        equals(const [
          {'featureFlag': 'demo-mode'},
          {'featureFlag': 'sample-group', 'variant': 'a'},
        ]),
      );
    });

    test('runApp catches async exceptions', () async {
      channel.results['attach'] = true;
      channel.results['createEvent'] = null;

      await bugsnag.attach(runApp: () async {
        await Future.delayed(const Duration(milliseconds: 1));
        throw Exception('this is a laaaarge crisis');
      });

      await Future.delayed(const Duration(milliseconds: 3));

      expect(channel['createEvent'], hasLength(1));
      expect(channel['createEvent'][0]['deliver'], isTrue);
    });

    test('runApp catches start exceptions', () async {
      channel.results['start'] = true;
      channel.results['createEvent'] = null;

      await bugsnag.start(runApp: () async {
        await Future.delayed(const Duration(milliseconds: 1));
        throw Exception('this is a laaaarge crisis');
      });

      await Future.delayed(const Duration(milliseconds: 3));

      expect(channel['createEvent'], hasLength(1));
      expect(channel['createEvent'][0]['deliver'], isTrue);
    });
  });
}
