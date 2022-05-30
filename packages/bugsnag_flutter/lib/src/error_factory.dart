import 'package:bugsnag_flutter/src/bugsnag_stacktrace.dart';

import 'model/event.dart';
import 'model/stackframe.dart';

class BugsnagErrorFactory {
  static const instance = BugsnagErrorFactory._internal();

  const BugsnagErrorFactory._internal();

  BugsnagError createError(dynamic error, [StackTrace? stackTrace]) {
    // we favour the stackTrace on the `error` object, if one exists as this is
    // where the error was first thrown
    final errorStackTraceString = _getErrorStackTraceString(error);

    // as a fallback we use the StackTrace that was passing in as `stackTrace`
    final stackTraceString = errorStackTraceString ?? stackTrace?.toString();
    final bugsnagStacktrace = stackTraceString != null
        ? parseStackTraceString(stackTraceString)
        : null;

    return BugsnagError(
      error.runtimeType.toString(),
      _safeMessageForError(error),
      bugsnagStacktrace ?? _fallbackStacktrace(),
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

  String? _getErrorStackTraceString(dynamic error) {
    try {
      final stack = error.stackTrace;
      if (stack is StackTrace) {
        return stack.toString();
      } else if (stack is String) {
        return stack;
      }
    } catch (e) {
      // the error clearly doesn't have a usable stackTrace field, go to fallback
    }

    return null;
  }

  BugsnagStacktrace _fallbackStacktrace() =>
      parseStackTraceString(StackTrace.current.toString())!;

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
