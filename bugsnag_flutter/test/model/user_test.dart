import 'dart:convert';
import 'dart:io';

import 'package:bugsnag_flutter/src/model/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    test('encodes / decodes from json', () {
      final user = User(
        id: 'abc123',
        email: 'test-user@bugsnag.com',
        name: 'Bobby Tables',
      );

      final unmarshalled = User.fromJson(user.toJson());
      expect(unmarshalled, equals(user));
    });

    test('encodes to expected json', () {
      const json = {
        'id': '321bca',
        'email': 'another-test-user@bugsnag.com',
        'name': 'Bobby Tables',
      };

      final user = User(
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

      final expectedUser = User(
        id: '321bca',
        email: 'definitely-not-the@inquisition.com',
        name: 'Unexpected Michael',
      );

      expect(User.fromJson(json), equals(expectedUser));
    });

    test('decodes from json fixture', () async {
      final userJsonFile = File('test/fixtures/user_serialization.json');
      final json = jsonDecode(await userJsonFile.readAsString());

      final user = User.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.email, equals('bob@example.com'));
      expect(user.name, equals('Bob Tables'));
    });
  });
}
