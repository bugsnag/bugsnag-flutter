import 'package:bugsnag_flutter/bugsnag.dart';
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

    test('from Android', () {
      const androidError = <String, dynamic>{
        'errorClass': 'java.lang.NullPointerException',
        'message': 'user',
        'type': 'android',
        'stacktrace': [
          {
            'file': 'BaseCrashyActivity.kt',
            'method':
                'com.example.bugsnag.android.BaseCrashyActivity\$onCreate\$2.onClick',
            'lineNumber': 39,
            'inProject': true,
          }
        ]
      };

      final error = Error.fromJson(androidError);
      expect(error.errorClass, equals('java.lang.NullPointerException'));
      expect(error.message, equals('user'));
      expect(error.type, equals(ErrorType.android));

      expect(error.stacktrace, hasLength(1));
      expect(error.stacktrace[0].file, equals('BaseCrashyActivity.kt'));
      expect(
          error.stacktrace[0].method,
          equals(
              'com.example.bugsnag.android.BaseCrashyActivity\$onCreate\$2.onClick'));
      expect(error.stacktrace[0].lineNumber, equals(39));
      expect(error.stacktrace[0].inProject, isTrue);
    });

    test('from iOS', () {
      const iosError = <String, dynamic>{
        'message': 'my error message',
        'errorClass': 'NSInvalidArgumentException',
        'type': 'cocoa',
        'stacktrace': [
          {
            'method': '\$s12macOSTestApp27BareboneTestHandledScenarioC3runyyF',
            'machoVMAddress': '0x100000000',
            'machoFile':
                '/Users/nick/Repos/bugsnag-cocoa/features/fixtures/macos/output/macOSTestApp.app/Contents/MacOS/macOSTestApp',
            'isPC': true,
            'symbolAddress': '0x1087ca5e0',
            'machoUUID': 'AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E',
            'machoLoadAddress': '0x1087b1000',
            'frameAddress': '0x1087cab00'
          },
        ],
      };

      final error = Error.fromJson(iosError);
      expect(error.errorClass, equals('NSInvalidArgumentException'));
      expect(error.message, equals('my error message'));
      expect(error.type, equals(ErrorType.cocoa));

      expect(error.stacktrace, hasLength(1));
      expect(error.stacktrace[0].method,
          equals('\$s12macOSTestApp27BareboneTestHandledScenarioC3runyyF'));
      expect(error.stacktrace[0].machoVMAddress, equals('0x100000000'));
      expect(
          error.stacktrace[0].machoFile,
          equals(
              '/Users/nick/Repos/bugsnag-cocoa/features/fixtures/macos/output/macOSTestApp.app/Contents/MacOS/macOSTestApp'));
      expect(error.stacktrace[0].isPC, isTrue);
      expect(error.stacktrace[0].symbolAddress, '0x1087ca5e0');
      expect(error.stacktrace[0].machoUUID,
          'AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E');
      expect(error.stacktrace[0].machoLoadAddress, '0x1087b1000');
      expect(error.stacktrace[0].frameAddress, '0x1087cab00');
    });
  });
}
