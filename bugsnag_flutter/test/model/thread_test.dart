import 'package:bugsnag_flutter/model.dart';
import 'package:flutter_test/flutter_test.dart';

import '_json_equals.dart';

void main() {
  group('Thread', () {
    test('from Android', () {
      const json = {
        'id': 24,
        'name': 'main-one',
        'type': 'android',
        'state': 'RUNNABLE',
        'stacktrace': [
          {'method': 'run_func', 'file': 'librunner.so', 'lineNumber': 5038},
          {'method': 'Runner.runFunc', 'file': 'Runner.java', 'lineNumber': 14},
          {'method': 'App.launch', 'file': 'App.java', 'lineNumber': 70}
        ]
      };

      final thread = Thread.fromJson(json);

      expect(thread.id, equals('24'));
      expect(thread.name, equals('main-one'));
      expect(thread.type, equals(ThreadType.android));
      expect(thread.state, equals('RUNNABLE'));
      expect(thread.isErrorReportingThread, isFalse);

      final stacktrace = thread.stacktrace;
      expect(stacktrace, hasLength(3));

      expect(stacktrace[0].method, equals('run_func'));
      expect(stacktrace[0].file, equals('librunner.so'));
      expect(stacktrace[0].lineNumber, equals(5038));

      expect(stacktrace[1].method, equals('Runner.runFunc'));
      expect(stacktrace[1].file, equals('Runner.java'));
      expect(stacktrace[1].lineNumber, equals(14));

      expect(stacktrace[2].method, equals('App.launch'));
      expect(stacktrace[2].file, equals('App.java'));
      expect(stacktrace[2].lineNumber, equals(70));

      expect(
        thread,
        jsonEquals({
          'id': '24',
          'name': 'main-one',
          'type': 'android',
          'state': 'RUNNABLE',
          'stacktrace': [
            {'method': 'run_func', 'file': 'librunner.so', 'lineNumber': 5038},
            {
              'method': 'Runner.runFunc',
              'file': 'Runner.java',
              'lineNumber': 14
            },
            {'method': 'App.launch', 'file': 'App.java', 'lineNumber': 70}
          ]
        }),
      );
    });

    test('from NDK', () {
      const json = {
        'id': 2345,
        'name': 'Jit Worker',
        'type': 'c',
        'state': 'sleeping',
      };

      final thread = Thread.fromJson(json);
      expect(thread.id, equals('2345'));
      expect(thread.name, equals('Jit Worker'));
      expect(thread.type, equals(ThreadType.c));
      expect(thread.state, equals('sleeping'));
      expect(thread.stacktrace, isEmpty);
      expect(thread.isErrorReportingThread, isFalse);

      expect(
        thread,
        jsonEquals(const {
          'id': '2345',
          'name': 'Jit Worker',
          'type': 'c',
          'state': 'sleeping',
          'stacktrace': [],
        }),
      );
    });

    test('from iOS', () {
      const json = {
        'errorReportingThread': true,
        'id': '0',
        'stacktrace': [
          {
            'method': '__exceptionPreprocess',
            'machoVMAddress': '0x7fff2030f000',
            'machoFile':
                '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
            'isPC': true,
            'symbolAddress': '0x7fff20420a04',
            'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
            'machoLoadAddress': '0x7fff2030f000',
            'frameAddress': '0x7fff20420ae6'
          },
          {
            'method': 'objc_exception_throw',
            'machoVMAddress': '0x7fff20172000',
            'machoFile':
                '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libobjc.A.dylib',
            'symbolAddress': '0x7fff20177e48',
            'machoUUID': '0ED2E6A3-D7FC-3A31-A1CA-6BE106521240',
            'machoLoadAddress': '0x7fff20172000',
            'frameAddress': '0x7fff20177e78'
          },
        ],
        'type': 'cocoa'
      };

      final thread = Thread.fromJson(json);

      expect(thread.id, equals('0'));
      expect(thread.isErrorReportingThread, isTrue);
      expect(thread.type, ThreadType.cocoa);

      final stacktrace = thread.stacktrace;
      expect(stacktrace, hasLength(2));

      expect(stacktrace[0].method, equals('__exceptionPreprocess'));
      expect(stacktrace[0].machoVMAddress, equals('0x7fff2030f000'));
      expect(
        stacktrace[0].machoFile,
        equals(
          '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
        ),
      );
      expect(stacktrace[0].isPC, isTrue);
      expect(stacktrace[0].symbolAddress, equals('0x7fff20420a04'));
      expect(stacktrace[0].machoUUID,
          equals('8FC68AD0-5128-3700-9E63-F6F358B6321B'));
      expect(stacktrace[0].machoLoadAddress, equals('0x7fff2030f000'));
      expect(stacktrace[0].frameAddress, equals('0x7fff20420ae6'));

      expect(stacktrace[1].method, equals('objc_exception_throw'));
      expect(stacktrace[1].machoVMAddress, equals('0x7fff20172000'));
      expect(
        stacktrace[1].machoFile,
        equals(
          '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libobjc.A.dylib',
        ),
      );
      expect(stacktrace[1].isPC, isNull);
      expect(stacktrace[1].symbolAddress, equals('0x7fff20177e48'));
      expect(stacktrace[1].machoUUID,
          equals('0ED2E6A3-D7FC-3A31-A1CA-6BE106521240'));
      expect(stacktrace[1].machoLoadAddress, equals('0x7fff20172000'));
      expect(stacktrace[1].frameAddress, equals('0x7fff20177e78'));

      expect(thread, jsonEquals(json));
    });
  });
}
