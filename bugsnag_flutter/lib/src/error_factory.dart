import 'package:bugsnag_flutter/src/native_stacktrace.dart';
import 'package:flutter/foundation.dart';

import 'model/event.dart';
import 'model/stackframe.dart';

class ErrorFactory {
  static const instance = ErrorFactory._internal();

  const ErrorFactory._internal();

  Error createError(dynamic error, [StackTrace? stackTrace]) {
    // we favour the stackTrace on the `error` object, if one exists as this is
    // where the error was first thrown
    final stack = _stackTraceFrom(error) ??
        (stackTrace != null
            ? _parseStackTrace(stackTrace)
            : _fallbackStacktrace());

    return Error(
      error.runtimeType.toString(),
      _safeMessageForError(error),
      stack,
    );
  }

  String _safeMessageForError(dynamic error) {
    if (error is String) {
      return error;
    } else {
      final String errorString;
      try {
        errorString = error.toString();
      } catch (e) {
        return '[exception]: $e';
      }

      try {
        final errorTypeName = error.runtimeType.toString();

        // we look to see if the toString() follows the common convention
        // '$typeName: $message'
        // if it does, we trim the type name off the front, since that is
        // send as Error.className and not removing it results in the error
        // being displayed as:
        // 'ErrorType ErrorType: message'
        // on the Dashboard
        var expectedErrorPrefix = '$errorTypeName: ';
        if (errorString.startsWith(expectedErrorPrefix)) {
          return errorString.substring(expectedErrorPrefix.length);
        } else {
          // this is required because some private classes (looking at you _Exception)
          // render themselves as a "public" name (ie: Exception).
          final trimmedErrorPrefix = '${_displayTypeNameOf(errorTypeName)}: ';
          if (errorString.startsWith(trimmedErrorPrefix)) {
            return errorString.substring(trimmedErrorPrefix.length);
          }
        }
      } catch (e) {
        // fallback: return the raw toString() value
      }

      return errorString;
    }
  }

  Stacktrace? _stackTraceFrom(dynamic error) {
    try {
      final stack = error.stackTrace;
      if (stack is StackTrace) {
        return parseNativeStackTrace(stack.toString()) ??
            _parseStackTrace(stack);
      } else if (stack is String) {
        return parseNativeStackTrace(stack) ??
            _parseStackTrace(StackTrace.fromString(stack));
      }
    } catch (e) {
      // the error clearly doesn't have a usable stackTrace field, go to fallback
    }

    return null;
  }

  Stacktrace _parseStackTrace(StackTrace stackTrace) =>
      StackFrame.fromStackTrace(stackTrace)
          .map(Stackframe.fromStackFrame)
          .toList();

  Stacktrace _fallbackStacktrace() => _parseStackTrace(StackTrace.current);

  /// Extract the probable "Display name" for an error based on it's type.
  /// This method trims any `_` off the front of the type name.
  String _displayTypeNameOf(String typeName) {
    int startIndex = 0;
    while (typeName[startIndex] == '_' && startIndex < typeName.length) {
      startIndex++;
    }

    return typeName.substring(startIndex);
  }
}
