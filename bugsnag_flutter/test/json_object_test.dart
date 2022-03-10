import 'package:bugsnag_flutter/stackframe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonObject', () {
    test('toJson removes nulls', () {
      expect(JsonObject.fromJson({'foo': 'bar', 'test': null}).toJson(),
          {'foo': 'bar'});
    });
  });
}
