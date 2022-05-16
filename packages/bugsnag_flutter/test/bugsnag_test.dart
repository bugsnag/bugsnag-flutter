import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_channel.dart';

void main() {
  final channel = MockChannelClientController();

  group('Bugsnag', () {
    setUp(() {
      channel.reset();
    });

    test('attach', () async {
      channel.results['attach'] = true;

      await bugsnag.attach();

      expect(channel['attach'], hasLength(1));
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

    test('default projectPackages', () async {
      channel.results['start'] = true;
      await bugsnag.start();

      // file "packages" are <unknown>
      expect(
        channel['start'][0]['projectPackages']['packageNames'][0],
        equals('<unknown>'),
      );

      // we should request platform default-packages by default
      expect(channel['start'][0]['projectPackages']['includeDefaults'], isTrue);
    });
  });
}
