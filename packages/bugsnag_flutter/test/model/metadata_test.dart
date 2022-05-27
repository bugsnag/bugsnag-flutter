import 'package:bugsnag_flutter/src/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Metadata', () {
    test('is empty by default', () {
      final metadata = BugsnagMetadata();
      expect(metadata.getMetadata('test'), null);
    });

    test('addMetadata merges with existing content', () {
      final metadata = BugsnagMetadata({
        'test': {'a': 'b'}
      });
      metadata.addMetadata('test', {'x': 'y'});
      expect(metadata.getMetadata('test'), {'a': 'b', 'x': 'y'});
    });

    test('clearMetadata with no key removes entire section', () {
      final metadata = BugsnagMetadata({
        'test': {'a': 'b'}
      });
      metadata.clearMetadata('test');
      expect(metadata.getMetadata('test'), null);
    });

    test('clearMetadata with key removes a single element', () {
      final metadata = BugsnagMetadata({
        'test': {'a': 'b', 'x': 'y'}
      });
      metadata.clearMetadata('test', 'a');
      expect(metadata.getMetadata('test'), {'x': 'y'});
    });

    test('sanitizedMap replaces invalid types with strings', () {
      expect(
        BugsnagMetadata.sanitizedMap({
          'array': [1, 2, 3, 4, 'foo'],
          'set': <dynamic>{},
          'number': 666,
          'message': 'Hello, World!',
          'color': const Color(0xff000000),
          'map': {'name': 'Foo', 'job': 'Barman'},
          'bad_map': {'car': 'Ferrari', 'color': const Color(0xffff0000)},
          'dodgy': const Dodgy(),
          'empty_array': [],
          'empty_object': {}
        }),
        equals({
          'array': [1, 2, 3, 4, 'foo'],
          'set': [],
          'number': 666,
          'message': 'Hello, World!',
          'color': 'Color(0xff000000)',
          'map': {'name': 'Foo', 'job': 'Barman'},
          'bad_map': {'car': 'Ferrari', 'color': 'Color(0xffff0000)'},
          'dodgy': '[exception]: DodgyException',
          'empty_array': [],
          'empty_object': {}
        }),
      );
    });

    test('Metadata equality', () {
      final m1 = BugsnagMetadata();
      final m2 = BugsnagMetadata();

      m1.addMetadata('some new data', const {
        'number': 12345,
        'boolean': false,
        'dodgy': Dodgy(),
      });

      m2.addMetadata('some new data', const {
        'number': 12345,
        'boolean': false,
        'dodgy': Dodgy(),
      });

      expect(m1, equals(m2));
    });
  });
}

class Dodgy {
  const Dodgy();

  @override
  String toString() {
    throw 'DodgyException';
  }
}
