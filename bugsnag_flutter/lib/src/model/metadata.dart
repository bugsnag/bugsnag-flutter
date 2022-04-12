import '_model_extensions.dart';

typedef MetadataSection = Map<String, Object>;
typedef MetadataMap = Map<String, MetadataSection>;

class BugsnagMetadata {
  final MetadataMap _map;

  BugsnagMetadata([MetadataMap map = const {}]) : this.fromJson(map);

  BugsnagMetadata.fromJson(Map<String, dynamic> json)
      : _map = json.map((key, val) => MapEntry(key, sanitizedMap(val)));

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BugsnagMetadata &&
          runtimeType == other.runtimeType &&
          _map.deepEquals(other._map);

  @override
  int get hashCode => _map.hashCode;

  @override
  String toString() => _map.toString();

  static MetadataSection sanitizedMap(Map<String, dynamic> map) {
    return map.map((key, val) => MapEntry(key, _sanitizedValue(val)));
  }

  static Object _sanitizedValue(dynamic value) {
    if (value is String || value is num || value is bool) return value;
    if (value is Map<String, dynamic>) return sanitizedMap(value);
    // Special case because empty Maps wil not be caught on previous line
    if (value is Map && value.isEmpty) return value;
    if (value is Iterable) return value.map((e) => _sanitizedValue(e));
    try {
      return '$value';
    } catch (e) {
      return '[exception]: $e';
    }
  }
}
