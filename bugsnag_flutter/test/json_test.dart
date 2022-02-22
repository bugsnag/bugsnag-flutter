import 'package:bugsnag_flutter/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('encode/decodes from json', () {
    test('User', () {
      const user = User(
        id: 'abc123',
        email: 'test-user@bugsnag.com',
        name: 'Bobby Tables',
      );

      final unmarshalled = User.fromJson(user.toJson());
      expect(unmarshalled, equals(user));
    });

    test('StackElement', () {
      final stackElement = StackElement(
        method: 'noSuchMethod',
        file: 'object.dart',
        lineNumber: 1234,
        inProject: false,
        code: {
          '100': 'someCodeHere',
          '101': 'more_code_here',
        },
        frameAddress: 837246,
        symbolAddress: 362845,
        loadAddress: 3278645,
        isPC: true,
        type: ErrorType.flutter,
      );

      final unmarshalled = StackElement.fromJson(stackElement.toJson());
      expect(unmarshalled, equals(stackElement));
    });
  });
}
