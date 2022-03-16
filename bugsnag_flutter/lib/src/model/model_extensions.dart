part of model;

bool _objectDeepEquals(Object? v1, Object? v2) {
  if (v1 == v2) return true;

  if (v1 is Map && v2 is Map) {
    return v1.deepEquals(v2);
  } else if (v1 is Iterable && v2 is Iterable) {
    return v1.deepEquals(v2);
  }

  return false;
}

extension _ObjectExtensions<T> on T {
  /// Call `mapper` with `this` and return the result. This is largely used in
  /// JSON conversion methods with ?. to play-nicely with nullable values and
  /// non-nullable arguments in constructors:
  ///
  /// ```dart
  /// user = _json.safeGet<Map<String, dynamic>>('user')?.let(User.fromUser)
  /// ```
  ///
  /// This behaviour is strictly a `map` but named `let` (as in Kotlin) to avoid
  /// further overloading that already overloaded name.
  R let<R>(R Function(T) mapper) => mapper(this);
}

extension _MapExtensions<K, V> on Map<K, V> {
  R? safeGet<R>(K key) {
    final actualValue = this[key];
    return actualValue is R ? actualValue : null;
  }

  bool deepEquals(Map<K, V> other) {
    if (length != other.length) return false;

    for (final k in keys) {
      final v1 = this[k];
      final v2 = other[k];

      if (!_objectDeepEquals(v1, v2)) {
        return false;
      }
    }

    return true;
  }

  bool isImmutable() {
    if (isNotEmpty) {
      // attempt a no-op mutation and see if we get an exception
      try {
        final entry = entries.first;
        this[entry.key] = entry.value;
      } catch (e) {
        return true;
      }

      return false;
    }
    // we assume that it's immutable for safety
    return true;
  }

  Map<K, V> asMutable() {
    if (isImmutable()) {
      return map((key, value) {
        if (value is Map) {
          return MapEntry(
              key, (value as Map<String, dynamic>).asMutable() as V);
        } else {
          return MapEntry(key, value);
        }
      });
    } else {
      return this;
    }
  }
}

extension _IterableExtensions<E> on Iterable<E> {
  bool deepEquals(Iterable<E> other) {
    if (length != other.length) return false;

    final otherIterator = other.iterator;
    for (final v1 in this) {
      if (!otherIterator.moveNext()) {
        // weird, length should have handled this case
        return false;
      }

      final v2 = otherIterator.current;
      if (!_objectDeepEquals(v1, v2)) {
        return false;
      }
    }

    return true;
  }
}
