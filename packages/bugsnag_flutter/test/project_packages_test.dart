import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectPackages', () {
    test('withDefaults', () {
      const testPackages = ProjectPackages.withDefaults({'my_package_name'});

      expect(
        testPackages.toJson(),
        equals({
          'includeDefaults': true,
          'packageNames': ['my_package_name'],
        }),
      );
    });

    test('only', () {
      const testPackages = ProjectPackages.only({'my_package_name'});

      expect(
        testPackages.toJson(),
        equals({
          'includeDefaults': false,
          'packageNames': ['my_package_name'],
        }),
      );
    });
  });
}
