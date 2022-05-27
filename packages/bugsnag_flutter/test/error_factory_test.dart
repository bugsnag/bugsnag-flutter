import 'package:bugsnag_flutter/src/error_factory.dart';
import 'package:bugsnag_flutter/src/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorFactory', () {
    test('Exception with String message', () {
      final error = BugsnagErrorFactory.instance
          .createError(Exception('this is a message'));

      expect(error.type, equals(BugsnagErrorType.dart));
      // a surprise _ appears!
      expect(error.errorClass, equals('_Exception'));
      expect(error.message, equals('this is a message'));
      expect(error.stacktrace.length, greaterThan(3));
    });

    test('Exception with an object message', () {
      final error = BugsnagErrorFactory.instance.createError(Exception(main));

      expect(error.type, equals(BugsnagErrorType.dart));
      // a surprise _ appears!
      expect(error.errorClass, equals('_Exception'));
      expect(error.message,
          equals('Closure: () => void from Function \'main\': static.'));
      expect(error.stacktrace.length, greaterThan(3));
    });

    test('Complex Exception with message', () {
      const exception =
          FormatException('could not parse input', 'invalid input', 0);
      final error = BugsnagErrorFactory.instance.createError(exception);

      expect(error.type, equals(BugsnagErrorType.dart));
      expect(error.errorClass, equals('FormatException'));
      expect(
        error.message,
        equals(
          'could not parse input (at character 1)\ninvalid input\n^\n',
        ),
      );
      expect(error.stacktrace.length, greaterThan(3));
    });

    test('Simple FlutterError', () {
      final flutterError = FlutterError('This is a FlutterError');
      final error = BugsnagErrorFactory.instance.createError(flutterError);

      expect(error.type, equals(BugsnagErrorType.dart));
      expect(error.errorClass, equals('FlutterError'));
      expect(error.message, equals('This is a FlutterError'));
      expect(error.stacktrace.length, greaterThan(3));
    });

    test('Detailed FlutterError', () {
      final flutterError = FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('FlutterError with more details'),
        ErrorDescription('This is where the details and description would go.'),
        DiagnosticsProperty<String>(
          'Malformed',
          'some bad string',
          expandableValue: true,
          showSeparator: true,
          style: DiagnosticsTreeStyle.whitespace,
        ),
      ]);

      final error = BugsnagErrorFactory.instance.createError(flutterError);

      expect(error.type, equals(BugsnagErrorType.dart));
      expect(error.errorClass, equals('FlutterError'));
      expect(
        error.message,
        equals(
          'FlutterError with more details\n'
          'This is where the details and description would go.\n'
          'Malformed: some bad string',
        ),
      );
      expect(error.stacktrace.length, greaterThan(3));
    });

    test('BadlyBehavedError', () {
      final error =
          BugsnagErrorFactory.instance.createError(BadlyBehavedError());

      expect(error.type, equals(BugsnagErrorType.dart));
      expect(error.errorClass, equals('BadlyBehavedError'));
      expect(error.message, equals('[exception]: error in toString'));
      expect(error.stacktrace.length, greaterThan(3));
    });

    test('Thrown number', () {
      final error = BugsnagErrorFactory.instance.createError(123);

      expect(error.type, equals(BugsnagErrorType.dart));
      expect(error.errorClass, equals('int'));
      expect(error.message, equals('123'));
      expect(error.stacktrace.length, greaterThan(3));
    });

    test('Error with stackTrace', () {
      final FlutterError thrownError;
      try {
        // the first throw of an Error fills in it's stackTrace
        throw FlutterError('message');
      } on FlutterError catch (e) {
        thrownError = e;
      }

      final error = BugsnagErrorFactory.instance.createError(thrownError);
      expect(error.errorClass, equals('FlutterError'));
      expect(error.stacktrace.length, greaterThan(1));

      // the top frame should be where the Error was *thrown*, which is this
      // file and the main() method:
      expect(error.stacktrace[0].file, endsWith('error_factory_test.dart'));
      expect(error.stacktrace[0].method, equals('main'));
    });
  });
}

class BadlyBehavedError {
  @override
  String toString() {
    throw 'error in toString';
  }
}
