import 'package:bugsnag_flutter/src/bugsnag_stacktrace.dart';
import 'package:bugsnag_flutter/src/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('native stacktrace', () {
    test('parses as Stacktrace', () {
      final stacktrace = parseNativeStackTrace(obfuscatedStackTrace);

      expect(stacktrace, isNotNull);
      expect(stacktrace, hasLength(7));

      expect(
        stacktrace!.map((f) => f.codeIdentifier),
        everyElement('b6951c7f8ae5ea368e83b65d81ff5c91'),
      );

      expect(
        stacktrace.map((f) => f.loadAddress),
        everyElement('0x7c9f10502c30'),
      );

      expect(
        stacktrace.map((f) => f.method),
        everyElement('_kDartIsolateSnapshotInstructions'),
      );

      expect(
        stacktrace.map((f) => f.type),
        everyElement(BugsnagErrorType.dart),
      );

      expect(
        stacktrace.map((f) => f.frameAddress),
        equals(const [
          '0x7c9f1063fae6',
          '0x7c9f106b9034',
          '0x7c9f1067cdc7',
          '0x7c9f10678409',
          '0x7c9f1067c291',
          '0x7c9f10678409',
          '0x7c9f106848a5',
        ]),
      );
    });

    test('parses iOS Stacktrace', () {
      final stacktrace = parseNativeStackTrace(obfuscatedStackTraceIOS);

      expect(stacktrace, isNotNull);
      expect(stacktrace, hasLength(4));

      expect(
        stacktrace!.map((f) => f.codeIdentifier),
        everyElement(isNull),
      );

      expect(
        stacktrace
            .map((f) => f.loadAddress)
            .where((element) => element != null),
        everyElement('0x10bfc7840'),
      );

      expect(
        stacktrace.map((f) => f.method),
        equals(const [
          '_kDartIsolateSnapshotInstructions',
          'asynchronous suspension',
          '_kDartIsolateSnapshotInstructions',
          'asynchronous suspension',
        ]),
      );

      expect(
        stacktrace.map((f) => f.frameAddress),
        equals(const [
          '0x10c207b77',
          null,
          '0x10c1f53e3',
          null,
        ]),
      );
    });

    test('parses invalid instruction addresses', () {
      final stacktrace = parseNativeStackTrace(invalidAddressStackTrace);

      expect(stacktrace, isNotNull);
      expect(stacktrace, hasLength(4));

      expect(
        stacktrace!.map((f) => f.method),
        equals(const [
          '_kDartIsolateSnapshotInstructions',
          'asynchronous suspension',
          'invalid Dart instruction address',
          'asynchronous suspension',
        ]),
      );
    });

    test('returns null for non-native StackTraces', () {
      final stacktrace = parseNativeStackTrace(StackTrace.current.toString());
      expect(stacktrace, isNull);
    });
  });

  group('parseStackTrace', () {
    test('parses StackTrace objects', () {
      final stacktrace = parseStackTraceString(StackTrace.current.toString());

      expect(stacktrace, isNotNull);
      expect(stacktrace!, hasLength(greaterThan(3)));

      expect(stacktrace[0].method, equals('main'));
      expect(stacktrace[0].file, endsWith('test/bugsnag_stacktrace_test.dart'));
    });

    test('parses StackTrace objects from classes', () {
      try {
        BuggyClass().throwException();
      } catch (_, stackTrace) {
        final stacktrace = parseStackTraceString(stackTrace.toString());

        expect(stacktrace, isNotNull);
        expect(stacktrace!, hasLength(greaterThan(3)));

        expect(stacktrace[0].method, equals('BuggyClass.throwException'));
        expect(stacktrace[1].method, equals('main'));
      }
    });
  });
}

class BuggyClass {
  void throwException() {
    throw Exception('BuggyClass throwing exceptions');
  }
}

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

const obfuscatedStackTraceIOS =
    'Apr  4 14:17:52 Runner(Flutter)[820] <Notice>: flutter: Warning: This VM has been configured to produce stack traces that violate the Dart standard.\n'
    '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***\n'
    'pid: 820, tid: 6105427968, name io.flutter.1.ui\n'
    'isolate_dso_base: 10bfbc000, vm_dso_base: 10bfbc000\n'
    'isolate_instructions: 10bfc7840, vm_instructions: 10bfc2ad0\n'
    '    #00 abs 000000010c207b77 _kDartIsolateSnapshotInstructions+0x240337\n'
    '    <asynchronous suspension>\n'
    '    #01 abs 000000010c1f53e3 _kDartIsolateSnapshotInstructions+0x22dba3\n'
    '    <asynchronous suspension>\n';

const invalidAddressStackTrace =
    'Warning: This VM has been configured to produce stack traces that violate the Dart standard.\n'
    '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***\n'
    'pid: 4714, tid: 4750, name 1.ui\n'
    'build_id: \'8deece9b6a5fc3491895d61fa03e8967\'\n'
    'isolate_dso_base: 6db6697000, vm_dso_base: 6db6697000\n'
    'isolate_instructions: 6db677b7f0, vm_instructions: 6db6777000\n'
    '#00 abs 0000006db69c1503 virt 000000000032a503 _kDartIsolateSnapshotInstructions+0x245d13\n'
    '<asynchronous suspension>\n'
    '#01 abs 0000000000000000 <invalid Dart instruction address>\n'
    '<asynchronous suspension>\n';
