import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter/foundation.dart';

// This file is heavily based on:
// https://github.com/dart-lang/sdk/blob/main/pkg/native_stack_traces/lib/src/convert.dart
// the primary difference is that we're only interested in the virtual address

final _traceLineRE = RegExp(
    r'\s*#(\d+) abs (?<absolute>[\da-f]+)(?: virt (?<virtual>[\da-f]+))? (?<rest>.*)$');

final _buildIdRegExp = RegExp(r"build_id: \'([a-f0-9]+)\'");
final _baseAddressRegExp = RegExp(r"isolate_dso_base: ([a-f0-9]+),");

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

// Try to parse the build_id from the line, returning it's value if it existed
String? _parseBuildId(String line) {
  final match = _buildIdRegExp.firstMatch(line);
  return match?.group(1);
}

// Try to parse the Isolate base address from the line (isolate_dso_base)
int? _parseBaseAddress(String line) {
  final match = _baseAddressRegExp.firstMatch(line);
  final matchedAddressString = match?.group(1);

  if (matchedAddressString != null) {
    return int.tryParse(matchedAddressString, radix: 16);
  }

  return null;
}

BugsnagStacktrace? _parseStackTrace(String stackTraceString) {
  try {
    return StackFrame.fromStackTrace(StackTrace.fromString(stackTraceString))
        .map(BugsnagStackframe.fromStackFrame)
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
  int? baseOffset;

  List<BugsnagStackframe> stacktrace = [];

  for (final line in stackTraceLines) {
    if (line.contains('<asynchronous suspension>')) {
      stacktrace.add(
        BugsnagStackframe.fromStackFrame(StackFrame.asynchronousSuspension),
      );
    } else {
      buildId ??= _parseBuildId(line);
      baseOffset ??= _parseBaseAddress(line);
      final frame = _Frame.parse(line);

      if (frame != null && baseOffset != null) {
        stacktrace.add(BugsnagStackframe(
          frameAddress: '0x' + frame.absoluteAddress.toRadixString(16),
          loadAddress: '0x' + baseOffset.toRadixString(16),
          codeIdentifier: buildId,
          method: frame.method,
        ));
      }
    }
  }

  return (stacktrace.isNotEmpty && baseOffset != null) ? stacktrace : null;
}

BugsnagStacktrace? parseStackTraceString(String stackTrace) {
  return parseNativeStackTrace(stackTrace) ?? _parseStackTrace(stackTrace);
}
