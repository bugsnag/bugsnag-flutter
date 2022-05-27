import 'dart:async';

import 'model.dart';

/// A callback to be run before error reports are sent to Bugsnag.
///
/// You can use this to add or modify information attached to an error
/// before it is sent to your dashboard. You can also return `false` from any
/// callback to halt execution.
///
/// "on error" callbacks added in Dart are only triggered for events originating
/// in Dart and will always be triggered before "on error" callbacks added
/// in the native layer (on Android and iOS).
typedef BugsnagOnErrorCallback = FutureOr<bool> Function(BugsnagEvent event);

typedef _Callback<E> = FutureOr<bool> Function(E);

typedef CallbackCollection<E> = Set<_Callback<E>>;

extension DispatchExtension<E> on CallbackCollection<E> {
  /// Dispatch the given [object] to every callback in this collection, returning
  /// `true` if processing should continue as usual. If any callback returns
  /// `false` then processing will stop and `dispatch` will return `false`
  /// immediately.
  Future<bool> dispatch(E object) async {
    if (isEmpty) {
      return true;
    }

    for (_Callback<E> callback in this) {
      final shouldContinue = await callback.invokeSafely(object);
      if (!shouldContinue) {
        return false;
      }
    }

    return true;
  }
}

extension InvokeSafelyExtension<E> on _Callback<E> {
  /// Invoke this callback safely replacing any errors with `true` to signal
  /// that processing should continue as normal.
  Future<bool> invokeSafely(E object) async {
    try {
      return await this(object);
    } catch (e) {
      // ignore: avoid_print
      print('[Bugsnag] callback threw an exception: $e');
      return true;
    }
  }
}
