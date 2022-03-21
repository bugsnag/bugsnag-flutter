import 'package:bugsnag_flutter/bugsnag.dart';
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

    test('produces expected JSON payloads', () {
      final flags = FeatureFlags();
      flags.addFeatureFlag('my-feature-flag');
      flags.addFeatureFlag('flag-with-variant', 'some variant');

      expect(
        flags.toJson(),
        equals([
          {'featureFlag': 'my-feature-flag'},
          {'featureFlag': 'flag-with-variant', 'variant': 'some variant'},
        ]),
      );
    });

    test('serializes & deserializes', () {
      final flags = FeatureFlags();
      flags.addFeatureFlag('flag-1');
      flags.addFeatureFlag('flag-2', 'a variant for flag-2');
      flags.addFeatureFlag('flag-3', 'a variant for flag-3');

      final deserializedFlags = FeatureFlags.fromJson(flags.toJson());
      expect(deserializedFlags, equals(flags));
    });
  });
}
