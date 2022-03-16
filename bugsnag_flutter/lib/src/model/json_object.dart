part of model;

class _JsonObject {
  final Map<String, Object?> _json;

  _JsonObject() : _json = {};

  _JsonObject.fromJson(Map<String, Object?> json) : _json = json.asMutable();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _JsonObject && _json.deepEquals(other._json);

  @override
  int get hashCode =>
      _json.entries.fold(0, (h, e) => h ^ Object.hash(e.key, e.value));

  dynamic toJson() {
    Map<String, Object> result = {};
    _json.forEach((k, v) => {if (v != null) result[k] = v});
    return result;
  }
}
