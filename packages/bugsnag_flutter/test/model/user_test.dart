import 'dart:convert';
import 'dart:io';

import 'package:bugsnag_flutter/src/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    test('encodes / decodes from json', () {
      final user = BugsnagUser(
        id: 'abc123',
        email: 'test-user@bugsnag.com',
        name: 'Bobby Tables',
      );

      final unmarshalled = BugsnagUser.fromJson(user.toJson());
      expect(unmarshalled, equals(user));
    });

    test('encodes to expected json', () {
      const json = {
        'id': '321bca',
        'email': 'another-test-user@bugsnag.com',
        'name': 'Bobby Tables',
      };

      final user = BugsnagUser(
        id: '321bca',
        email: 'another-test-user@bugsnag.com',
        name: 'Bobby Tables',
      );

      expect(user.toJson(), equals(json));
    });

    test('decodes from json', () {
      const json = {
        'id': '321bca',
        'email': 'definitely-not-the@inquisition.com',
        'name': 'Unexpected Michael',
      };

      final expectedUser = BugsnagUser(
        id: '321bca',
        email: 'definitely-not-the@inquisition.com',
        name: 'Unexpected Michael',
      );

      expect(BugsnagUser.fromJson(json), equals(expectedUser));
    });

    test('decodes from json fixture', () async {
      final userJsonFile = File('test/fixtures/user_serialization.json');
      final json = jsonDecode(await userJsonFile.readAsString());

      final user = BugsnagUser.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.email, equals('bob@example.com'));
      expect(user.name, equals('Bob Tables'));
    });
  });
}
