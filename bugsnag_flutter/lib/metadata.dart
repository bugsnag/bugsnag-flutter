typedef MetadataSection = Map<String, Object>;
typedef MetadataMap = Map<String, MetadataSection>;

class Metadata {
  
  MetadataMap map = {};

  Metadata([MetadataMap map = const {}]) {
    this.map = map.map((key, val) => MapEntry(key, sanitizedMap(val)));
  }

  void addMetadata(String section, MetadataSection metadata) {
    map.putIfAbsent(section, () => {}).addAll(sanitizedMap(metadata));
  }

  void clearMetadata(String section, [String? key]) {
    if (key == null) {
      map.remove(section);
    } else {
      map[section]?.remove(key);
    }
  }

  MetadataSection? getMetadata(String section) {
    return map[section];
  }

  MetadataMap toMap() {
    return map;
  }

  static MetadataSection sanitizedMap(Map<String, Object> map) {
    return map.map((key, val) => MapEntry(key, sanitizedObject(val)));
  }

  static Object sanitizedObject(Object object) {
    if (object is String || object is num) return object;
    if (object is Map<String, Object>) return sanitizedMap(object);
    if (object is Iterable) return object.map((e) => sanitizedObject(e));
    try {
      return "$object";
    } catch (e) {
      return "[exception]: $e";
    }
  }
}
