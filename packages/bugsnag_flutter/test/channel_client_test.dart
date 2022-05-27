import 'dart:async';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_flutter/src/client.dart';
import 'package:bugsnag_flutter/src/model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_channel.dart';

void main() {
  final channel = MockChannelClientController();

  group('ChannelClient', () {
    late ChannelClient client;
    setUp(() {
      client = ChannelClient(true);
      channel.reset({
        'attach': true,
        'createEvent': _mockCreateEvent,
        'deliverEvent': null,
      });
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

        await client.notify('no error', StackTrace.current);

        expect(secondCallbackInvoked, isTrue);
      });

      test('can block sending', () async {
        client.addOnError((event) => false);

        await client.notify('no error', StackTrace.current);

        expect(channel['deliverEvent'], hasLength(0));
      });

      test('can modify the event', () async {
        client.addOnError((event) {
          event.unhandled = true;
          event.threads = [];
          return true;
        });

        await client.notify('no error', StackTrace.current);

        expect(channel['deliverEvent'], hasLength(1));
        expect(channel['deliverEvent'][0]['threads'], hasLength(0));
        expect(channel['deliverEvent'][0]['unhandled'], isTrue);
        expect(
          channel['deliverEvent'][0]['severityReason']['unhandledOverridden'],
          isTrue,
        );
      });
    });

    group('Client.notify', () {
      test('delivers events in createEvent if possible', () async {
        channel.results['createEvent'] = null;
        await client.notify('no error', StackTrace.current);

        expect(channel['createEvent'], hasLength(1));
        expect(channel['createEvent'][0]['deliver'], isTrue);

        expect(channel['deliverEvent'], isEmpty);
      });

      test('delivers events with obfuscated stack traces', () async {
        channel.results['createEvent'] = null;
        await client.notify(
          'no error',
          StackTrace.fromString(obfuscatedStackTrace),
        );

        expect(channel['createEvent'], hasLength(1));
        expect(channel['createEvent'][0]['deliver'], isTrue);

        expect(channel['deliverEvent'], isEmpty);

        final error = channel['createEvent'][0]['error'];
        expect(error, isNotNull);
        expect(error['type'], equals('dart'));
        expect(error['stacktrace'], hasLength(7));
      });
    });

    group('errorHandler', () {
      test('delivers unhandled exceptions', () {
        runZonedGuarded(() {
          dynamic string = "this is not a number";
          return string / 10;
        }, client.errorHandler);

        expect(channel['createEvent'], hasLength(1));
        expect(channel['createEvent'][0]['deliver'], isTrue);

        expect(channel['deliverEvent'], isEmpty);
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
        expect(channel['createEvent'], hasLength(1));
        expect(channel['createEvent'][0]['deliver'], isTrue);
      });
    });
  });
}

BugsnagEvent _mockCreateEvent(arguments) => BugsnagEvent.fromJson({
      'metaData': <String, dynamic>{},
      'severity': 'warning',
      'unhandled': arguments['unhandled'],
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

const obfuscatedStackTrace =
    'Warning: This VM has been configured to produce stack traces that violate the Dart standard.\n'
    '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***\n'
    'pid: 5791, tid: 5815, name 1.ui\n'
    'build_id: \'b6951c7f8ae5ea368e83b65d81ff5c91\'\n'
    'isolate_dso_base: 7c9f10447000, vm_dso_base: 7c9f10447000\n'
    'isolate_instructions: 7c9f10502c30, vm_instructions: 7c9f104ff000\n'
    '    #00 abs 00007c9f1063fae6 virt 00000000001f8ae6 _kDartIsolateSnapshotInstructions+0x13ceb6\n'
    '    #01 abs 00007c9f106b9034 virt 0000000000272034 _kDartIsolateSnapshotInstructions+0x1b6404\n'
    '    #02 abs 00007c9f1067cdc7 virt 0000000000235dc7 _kDartIsolateSnapshotInstructions+0x17a197\n'
    '    #03 abs 00007c9f10678409 virt 0000000000231409 _kDartIsolateSnapshotInstructions+0x1757d9\n'
    '    #04 abs 00007c9f1067c291 virt 0000000000235291 _kDartIsolateSnapshotInstructions+0x179661\n'
    '    #05 abs 00007c9f10678409 virt 0000000000231409 _kDartIsolateSnapshotInstructions+0x1757d9\n'
    '    #06 abs 00007c9f106848a5 virt 000000000023d8a5 _kDartIsolateSnapshotInstructions+0x181c75\n';
