import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_channel.dart';

void main() {
  final channel = MockChannelClientController();

  group('Bugsnag', () {
    setUp(() {
      channel.reset();
    });

    test('attach', () async {
      channel.results['attach'] = {
        'config': {
          'enabledErrorTypes': {'dartErrors': true}
        }
      };

      await bugsnag.attach();

      expect(channel['attach'], hasLength(1));
    });

    test('default projectPackages', () async {
      channel.results['start'] = true;
      await bugsnag.start();

      // file "packages" are <unknown>
      expect(
        channel['start'][0]['projectPackages']['packageNames'],
        equals(const ['<unknown>']),
      );

      // we should request platform default-packages by default
      expect(channel['start'][0]['projectPackages']['includeDefaults'], isTrue);
    });

    test('default telemetry', () async {
      channel.results['start'] = true;
      await bugsnag.start();

      expect(
        channel['start'][0]['telemetry'],
        equals(const ['internalErrors', 'usage']),
      );
    });

    test('disabled telemetry', () async {
      channel.results['start'] = true;
      await bugsnag.start(telemetry: {});

      expect(
        channel['start'][0]['telemetry'],
        equals(const []),
      );
    });
  });
}
