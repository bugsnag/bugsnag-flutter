import 'package:bugsnag_flutter/src/model/event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Error', () {
    test('ErrorType identical', () {
      expect(ErrorType.flutter, same(ErrorType.forName('flutter')));
      expect(ErrorType.android, same(ErrorType.forName(('android'))));
      expect(ErrorType.cocoa, same(ErrorType.forName(('cocoa'))));
    });

    test('ErrorType equals', () {
      expect(
        ErrorType.forName('testing'),
        equals(ErrorType.forName('testing')),
      );
    });

    test('toString', () {
      expect(ErrorType.flutter.toString(), equals('flutter'));
      expect(ErrorType.android.toString(), equals('android'));
      expect(ErrorType.cocoa.toString(), equals('cocoa'));
      expect(ErrorType.c.toString(), equals('c'));
      expect(ErrorType.forName('testing').toString(), equals('testing'));
    });
  });
}
