part of model;

typedef MetadataSection = Map<String, Object>;
typedef MetadataMap = Map<String, MetadataSection>;

class Metadata {
  final MetadataMap _map;

  Metadata([MetadataMap map = const {}])
      : _map = map.map((key, val) => MapEntry(key, sanitizedMap(val)));

  void addMetadata(String section, MetadataSection metadata) {
    _map.putIfAbsent(section, () => {}).addAll(sanitizedMap(metadata));
  }

  void clearMetadata(String section, [String? key]) {
    if (key == null) {
      _map.remove(section);
    } else {
      _map[section]?.remove(key);
    }
  }

  MetadataSection? getMetadata(String section) => _map[section];

  MetadataMap toMap() => _map;

  dynamic toJson() => _map;

  static MetadataSection sanitizedMap(Map<String, Object> map) {
    return map.map((key, val) => MapEntry(key, sanitizedObject(val)));
  }

  static Object sanitizedObject(Object object) {
    if (object is String || object is num) return object;
    if (object is Map<String, Object>) return sanitizedMap(object);
    // Special case because empty Maps wil not be caught on previous line
    if (object is Map && object.isEmpty) return object;
    if (object is Iterable) return object.map((e) => sanitizedObject(e));
    try {
      return '$object';
    } catch (e) {
      return '[exception]: $e';
    }
  }
}
