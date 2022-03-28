import 'dart:async';

import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:bugsnag_flutter/src/client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

var createdEvents = <Map<String, dynamic>>[];
var deliveredEvents = <Map<String, dynamic>>[];

void main() {
  const channel = MethodChannel('com.bugsnag/client', JSONMethodCodec());
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, _handleClientMethodCall);

  group('ChannelClient', () {
    late ChannelClient client;
    setUp(() {
      client = ChannelClient();
      createdEvents.clear();
      deliveredEvents.clear();
    });

    group('OnError Callbacks', () {
      test('exceptions do not block processing', () async {
        var secondCallbackInvoked = false;
        client.addOnError((event) {
          throw Exception('unhandled exception in OnError');
        });

        client.addOnError((event) {
          secondCallbackInvoked = true;
          return true;
        });

        await client.notify('no error', stackTrace: StackTrace.current);

        expect(secondCallbackInvoked, isTrue);
      });

      test('can block sending', () async {
        client.addOnError((event) => false);

        await client.notify('no error', stackTrace: StackTrace.current);

        expect(deliveredEvents, hasLength(0));
      });

      test('can modify the event', () async {
        client.addOnError((event) {
          event.unhandled = true;
          event.threads = [];
          return true;
        });

        await client.notify('no error', stackTrace: StackTrace.current);

        expect(deliveredEvents, hasLength(1));
        expect(deliveredEvents[0]['threads'], hasLength(0));
        expect(deliveredEvents[0]['unhandled'], isTrue);
        expect(
          deliveredEvents[0]['severityReason']['unhandledOverridden'],
          isTrue,
        );
      });
    });

    group('Client.notify', () {
      test('delivers events in createEvent if possible', () async {
        await client.notify('no error', stackTrace: StackTrace.current);

        expect(createdEvents, hasLength(1));
        expect(createdEvents[0]['deliver'], isTrue);

        expect(deliveredEvents, isEmpty);
      });
    });

    group('errorHandler', () {
      test('delivers unhandled exceptions', () {
        runZonedGuarded(() {
          dynamic string = "this is not a number";
          return string / 10;
        }, client.errorHandler);

        expect(createdEvents, hasLength(1));
        expect(createdEvents[0]['deliver'], isTrue);

        expect(deliveredEvents, isEmpty);
      });

      test('runZoned helper', () {
        bool shouldThrowError() {
          return true;
        }

        final value = client.runZoned(() {
          if (shouldThrowError()) {
            throw Exception('this ia a test exception');
          }

          return 'hello';
        });

        expect(value, isNull);
        expect(createdEvents, hasLength(1));
        expect(createdEvents[0]['deliver'], isTrue);
      });
    });
  });
}

Future<Object?> _handleClientMethodCall(MethodCall message) async {
  if (message.method == 'attach') {
    return true;
  } else if (message.method == 'createEvent') {
    createdEvents.add(message.arguments);
    if (message.arguments['deliver']) {
      return null;
    }

    return Event.fromJson({
      'metaData': <String, dynamic>{},
      'severity': 'warning',
      'unhandled': message.arguments['unhandled'],
      'severityReason': {
        'type': 'unhandledException',
        'unhandledOverridden': false,
      },
      'session': {
        'id': 'abc123',
        'startedAt': '1970-01-01T00:00:00.000Z',
        'events': {
          'handled': 0,
          'unhandled': 0,
        },
      },
      'exceptions': [],
      'threads': [],
      'projectPackages': [],
      'breadcrumbs': [],
      'featureFlags': [],
      'user': {
        'id': 'user1',
      },
      'app': {
        'type': 'flutter',
        'versionCode': 0,
      },
      'device': {
        'cpuAbi': [],
        'manufacturer': 'samsung',
        'model': 's7',
        'osName': 'android',
        'osVersion': '7.1',
        'runtimeVersions': {
          'osBuild': 'bulldog',
          'androidApiLevel': '24',
        },
        'totalMemory': 109230923452,
        'freeDisk': 22234423124,
        'freeMemory': 92340255592,
        'orientation': 'portrait',
        'time': '1970-01-01T00:00:00.000Z',
      },
    });
  } else if (message.method == 'deliverEvent') {
    deliveredEvents.add(message.arguments);
  }
}
