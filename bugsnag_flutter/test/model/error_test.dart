import 'package:bugsnag_flutter/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Error', () {
    test('ErrorType equality', () {
      // Do not make these `const` - we want to check the == operator
      expect(ErrorType.flutter, equals(ErrorType('flutter')));
      expect(ErrorType.android, equals(ErrorType('android')));
      expect(ErrorType.cocoa, equals(ErrorType('cocoa')));
      expect(ErrorType('shoebox'), equals(ErrorType('shoebox')));
    });
  });
}
