import 'package:flutter/foundation.dart';

import 'model.dart';

// This file is heavily based on:
// https://github.com/dart-lang/sdk/blob/main/pkg/native_stack_traces/lib/src/convert.dart
// the primary difference is that we're only interested in the virtual address

final _traceLineRE = RegExp(
    r'\s*#(\d+) abs (?<absolute>[\da-f]+)(?: virt (?<virtual>[\da-f]+))? (?<rest>.*)$');

final _buildIdRegExp = RegExp(r"build_id: \'([a-f0-9]+)\'");
final _baseAddressHeaderRE = RegExp(
    r'isolate_instructions(?:=|: )([\da-f]+),? vm_instructions(?:=|: )([\da-f]+)');

class _Frame {
  final int absoluteAddress;
  final String? method;

  const _Frame(this.absoluteAddress, this.method);

  static final _symbolOffsetRE =
      RegExp(r'(?<symbol>\w+)\+(?<offset>(?:0x)?[\da-f]+)');

  static _Frame? parse(String line) {
    final match = _traceLineRE.firstMatch(line);
    if (match == null) return null;
    final addressString = match.namedGroup('absolute');
    final rest = match.namedGroup('rest');

    final address =
        addressString != null ? int.tryParse(addressString, radix: 16) : null;

    if (address != null) {
      return _Frame(address, _extractMethodName(rest));
    }

    return null;
  }

  static String? _extractMethodName(String? symbolString) {
    if (symbolString == null) {
      return null;
    }

    final match = _symbolOffsetRE.firstMatch(symbolString);
    return match?.namedGroup('symbol');
  }
}

class _AddressSegments {
  final int isolateBaseAddress;
  final int vmBaseAddress;

  final String _isolateBaseAddressString;
  final String _vmBaseAddressString;

  _AddressSegments(this.isolateBaseAddress, this.vmBaseAddress)
      : _isolateBaseAddressString = '0x' + isolateBaseAddress.toRadixString(16),
        _vmBaseAddressString = '0x' + vmBaseAddress.toRadixString(16);

  String baseAddressFor(String? symbol) {
    if (symbol == '_kDartVmSnapshotInstructions') {
      return _vmBaseAddressString;
    }

    return _isolateBaseAddressString;
  }
}

// Try to parse the build_id from the line, returning it's value if it existed
String? _parseBuildId(String line) {
  final match = _buildIdRegExp.firstMatch(line);
  return match?.group(1);
}

// Try to parse the Isolate base address from the line (isolate_dso_base)
_AddressSegments? _parseBaseAddress(String line) {
  final match = _baseAddressHeaderRE.firstMatch(line);
  final isolateBaseAddressString = match?.group(1);
  final vmBaseAddressString = match?.group(2);

  if (isolateBaseAddressString != null && vmBaseAddressString != null) {
    final isolateBase = int.tryParse(isolateBaseAddressString, radix: 16);
    final vmBase = int.tryParse(vmBaseAddressString, radix: 16);

    if (isolateBase != null && vmBase != null) {
      return _AddressSegments(isolateBase, vmBase);
    }
  }

  return null;
}

BugsnagStacktrace? _parseStackTrace(String stackTraceString) {
  try {
    return StackFrame.fromStackTrace(StackTrace.fromString(stackTraceString))
        .map((frame) => BugsnagStackframe.fromStackFrame(frame))
        .toList();
  } catch (e) {
    return null;
  }
}

/// If possible parse the given [stackTrace] as an obfuscated native stackTrace.
/// If the given `stackTrace` is not a valid native stack trace return `null`.
BugsnagStacktrace? parseNativeStackTrace(String stackTrace) {
  final stackTraceLines = stackTrace.split('\n');

  String? buildId;
  _AddressSegments? addressSegments;

  List<BugsnagStackframe> stacktrace = [];

  for (final line in stackTraceLines) {
    if (line.contains('<asynchronous suspension>')) {
      stacktrace.add(
        BugsnagStackframe.fromStackFrame(StackFrame.asynchronousSuspension),
      );
    } else {
      buildId ??= _parseBuildId(line);
      addressSegments ??= _parseBaseAddress(line);
      final frame = _Frame.parse(line);

      if (frame != null && addressSegments != null) {
        stacktrace.add(BugsnagStackframe(
          frameAddress: '0x' + frame.absoluteAddress.toRadixString(16),
          loadAddress: addressSegments.baseAddressFor(frame.method),
          codeIdentifier: buildId,
          method: frame.method,
          type: BugsnagErrorType.dart,
        ));
      }
    }
  }

  return (stacktrace.isNotEmpty && addressSegments != null) ? stacktrace : null;
}

BugsnagStacktrace? parseStackTraceString(String stackTrace) {
  return parseNativeStackTrace(stackTrace) ?? _parseStackTrace(stackTrace);
}
