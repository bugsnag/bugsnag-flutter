import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stackframe', () {
    test('from Android JVM', () {
      final json = {
        'method': 'android.os.Looper.loop',
        'file': 'Looper.java',
        'lineNumber': 158
      };

      final stackframe = BugsnagStackframe.fromJson(json);
      expect(stackframe.method, 'android.os.Looper.loop');
      expect(stackframe.file, 'Looper.java');
      expect(stackframe.lineNumber, 158);

      expect(stackframe.toJson(), json);
    });

    test('from Android NDK', () {
      final json = {
        'method': 'syscall',
        'file': '/system/lib64/libc.so',
        'lineNumber': 114912,
        'frameAddress': 548496896224,
        'symbolAddress': 548496896192,
        'loadAddress': 548496781312,
        'type': 'c'
      };

      final stackframe = BugsnagStackframe.fromJson(json);
      expect(stackframe.method, 'syscall');
      expect(stackframe.file, '/system/lib64/libc.so');
      expect(stackframe.lineNumber, 114912);
      expect(stackframe.frameAddress, '0x7fb4f670e0');
      expect(stackframe.symbolAddress, '0x7fb4f670c0');
      expect(stackframe.loadAddress, '0x7fb4f4b000');
      expect(stackframe.type, BugsnagErrorType.c);

      expect(stackframe.toJson(), json);
    });

    test('from Cocoa', () {
      final json = {
        'method': '\$s12macOSTestApp27BareboneTestHandledScenarioC3runyyF',
        'machoVMAddress': '0x100000000',
        'machoFile':
            '/Users/nick/Repos/bugsnag-cocoa/features/fixtures/macos/output/macOSTestApp.app/Contents/MacOS/macOSTestApp',
        'isPC': true,
        'symbolAddress': '0x1087ca5e0',
        'machoUUID': 'AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E',
        'machoLoadAddress': '0x1087b1000',
        'frameAddress': '0x1087cab00'
      };

      final stackframe = BugsnagStackframe.fromJson(json);
      expect(stackframe.method,
          '\$s12macOSTestApp27BareboneTestHandledScenarioC3runyyF');
      expect(stackframe.machoVMAddress, '0x100000000');
      expect(stackframe.machoFile,
          '/Users/nick/Repos/bugsnag-cocoa/features/fixtures/macos/output/macOSTestApp.app/Contents/MacOS/macOSTestApp');
      expect(stackframe.isPC, true);
      expect(stackframe.isLR, null);
      expect(stackframe.symbolAddress, '0x1087ca5e0');
      expect(stackframe.machoUUID, 'AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E');
      expect(stackframe.machoLoadAddress, '0x1087b1000');
      expect(stackframe.frameAddress, '0x1087cab00');

      expect(stackframe.toJson(), json);
    });

    test('from Dart', () {
      final currentFrames = StackFrame.fromStackTrace(StackTrace.current);
      for (StackFrame f in currentFrames) {
        final stackframe = BugsnagStackframe.fromStackFrame(f);
        expect(stackframe.file, endsWith(f.packagePath));
        expect(stackframe.lineNumber, f.line);
        expect(stackframe.columnNumber, f.column);
        expect(
          stackframe.method,
          f.className.isNotEmpty ? '${f.className}.${f.method}' : f.method,
        );
      }
    });
  });
}
