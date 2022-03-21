import 'package:bugsnag_flutter/src/native_stacktrace.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nativeStacktrace', () {
    test('parses as Stacktrace', () {
      final stacktrace = parseNativeStackTrace(obfuscatedStackTrace);

      expect(stacktrace, isNotNull);
      expect(stacktrace, hasLength(7));

      expect(
        stacktrace!.map((f) => f.codeIdentifier),
        everyElement('b6951c7f8ae5ea368e83b65d81ff5c91'),
      );

      expect(
        stacktrace.map((f) => f.frameAddress),
        equals(const [
          '0x1f8ae6',
          '0x272034',
          '0x235dc7',
          '0x231409',
          '0x235291',
          '0x231409',
          '0x23d8a5',
        ]),
      );
    });

    test('returns null for non-native StackTraces', () {
      final stacktrace = parseNativeStackTrace(StackTrace.current.toString());

      expect(stacktrace, isNull);
    });
  });
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
