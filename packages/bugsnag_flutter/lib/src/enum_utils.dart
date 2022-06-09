// The official EnumName extension was only added in 2.15
extension EnumName on Enum {
  String toName() => toString().split('.').last;
}

// The official EnumByName extension was only added in 2.15
extension EnumByName<T extends Enum> on Iterable<T> {
  T findByName(String name) {
    for (var value in this) {
      if (value.toName() == name) return value;
    }

    throw ArgumentError.value(name, "name", "No enum value with that name");
  }
}
