import 'package:bugsnag_flutter/src/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Error', () {
    test('ErrorType identical', () {
      expect(BugsnagErrorType.dart, same(BugsnagErrorType.forName('dart')));
      expect(BugsnagErrorType.android,
          same(BugsnagErrorType.forName(('android'))));
      expect(BugsnagErrorType.cocoa, same(BugsnagErrorType.forName(('cocoa'))));
    });

    test('ErrorType equals', () {
      expect(
        BugsnagErrorType.forName('testing'),
        equals(BugsnagErrorType.forName('testing')),
      );
    });

    test('toString', () {
      expect(BugsnagErrorType.dart.toString(), equals('dart'));
      expect(BugsnagErrorType.android.toString(), equals('android'));
      expect(BugsnagErrorType.cocoa.toString(), equals('cocoa'));
      expect(BugsnagErrorType.c.toString(), equals('c'));
      expect(BugsnagErrorType.forName('testing').toString(), equals('testing'));
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

      final error = BugsnagError.fromJson(androidError);
      expect(error.errorClass, equals('java.lang.NullPointerException'));
      expect(error.message, equals('user'));
      expect(error.type, equals(BugsnagErrorType.android));

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

      final error = BugsnagError.fromJson(iosError);
      expect(error.errorClass, equals('NSInvalidArgumentException'));
      expect(error.message, equals('my error message'));
      expect(error.type, equals(BugsnagErrorType.cocoa));

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
