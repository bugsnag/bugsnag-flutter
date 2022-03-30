import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Breadcrumbs', () {
    test('user breadcrumb toJson', () {
      final breadcrumb = Breadcrumb('starting out on a journey', metadata: {});
      final json = breadcrumb.toJson();

      expect(json['name'], equals('starting out on a journey'));
      expect(json['type'], equals('manual'));
      expect(json['metaData'], equals(<String, dynamic>{}));
      expect(json['timestamp'], endsWith('Z'));
    });

    test('breadcrumb with no metadata toJson', () {
      final breadcrumb = Breadcrumb('oak', type: BreadcrumbType.log);
      final json = breadcrumb.toJson();

      expect(json['name'], equals('oak'));
      expect(json['type'], equals('log'));
      expect(json['metaData'], {});
      expect(json['timestamp'], endsWith('Z'));
    });

    test('breadcrumb from json without metadata', () {
      const json = {
        'name': 'from all the way over the network',
        'type': 'request',
        'timestamp': '2022-03-03T02:15:50.405Z',
      };

      final breadcrumb = Breadcrumb.fromJson(json);
      expect(breadcrumb.message, equals('from all the way over the network'));
      expect(breadcrumb.type, equals(BreadcrumbType.request));
      expect(breadcrumb.metadata, isNull);
      expect(breadcrumb.timestamp,
          equals(DateTime.utc(2022, 3, 3, 2, 15, 50, 405)));
    });

    test('breadcrumb from json', () {
      const json = {
        'name': 'from all the way over the network',
        'type': 'request',
        'timestamp': '2022-03-03T02:15:50.405Z',
        'metaData': {'some string': 'value goes here'},
      };

      final breadcrumb = Breadcrumb.fromJson(json);
      expect(breadcrumb.message, equals('from all the way over the network'));
      expect(breadcrumb.type, equals(BreadcrumbType.request));
      expect(breadcrumb.metadata, equals({'some string': 'value goes here'}));
      expect(breadcrumb.timestamp,
          equals(DateTime.utc(2022, 3, 3, 2, 15, 50, 405)));
    });
  });
}
