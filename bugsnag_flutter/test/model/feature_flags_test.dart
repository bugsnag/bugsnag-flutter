import 'package:bugsnag_flutter/src/model/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';

import '_json_equals.dart';

void main() {
  group('FeatureFlags', () {
    test('decodes from json', () {
      const featureFlagJson = [
        {'featureFlag': 'demo-mode'},
        {'featureFlag': 'sample-group', 'variant': 'groupA'},
      ];

      final expectedFlags = FeatureFlags();
      expectedFlags.addFeatureFlag('demo-mode');
      expectedFlags['sample-group'] = 'groupA';

      final flags = FeatureFlags.fromJson(featureFlagJson);

      expect(flags, equals(expectedFlags));
      expect(flags, jsonEquals(expectedFlags));
    });

    test('can clear existing feature flags', () {
      final flags = FeatureFlags();
      flags.addFeatureFlag('my-feature-flag');
      flags.addFeatureFlag('flag-with-variant', 'some variant');
      flags.clearFeatureFlags();

      expect(flags.toJson(), equals(const []));
    });

    test('can clear single feature flags', () {
      final flags = FeatureFlags();
      flags.addFeatureFlag('my-feature-flag');
      flags.addFeatureFlag('flag-with-variant', 'some variant');

      flags.clearFeatureFlag('my-feature-flag');

      expect(
        flags.toJson(),
        equals(const [
          {'featureFlag': 'flag-with-variant', 'variant': 'some variant'},
        ]),
      );
    });
  });
}
