import 'dart:async';

import 'model.dart';

typedef OnErrorCallback = FutureOr<bool> Function(Event event);
typedef OnSessionCallback = FutureOr<bool> Function(Session session);
typedef OnBreadcrumbCallback = FutureOr<bool> Function(Breadcrumb breadcrumb);

typedef _Callback<E> = FutureOr<bool> Function(E);

typedef CallbackCollection<E> = Set<_Callback<E>>;

extension DispatchEventExtension<E> on CallbackCollection<E> {
  /// Dispatch the given [event] to every callback in this collection, returning
  /// `true` if processing should continue as usual. If any callback returns
  /// `false` then processing will stop and `dispatchEvent` will return `false`
  /// immediately.
  Future<bool> dispatchEvent(E event) async {
    if (isEmpty) {
      return true;
    }

    for (_Callback<E> callback in this) {
      final shouldContinue = await callback.invokeSafely(event);
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
  Future<bool> invokeSafely(E event) async {
    try {
      return await this(event);
    } catch (e) {
      return true;
    }
  }
}
