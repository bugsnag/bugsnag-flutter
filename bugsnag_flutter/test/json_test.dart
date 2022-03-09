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
  });
}
