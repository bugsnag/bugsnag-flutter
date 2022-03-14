part of bugsnag;

class _JsonObject {
  final Map<String, Object?> _json;

  _JsonObject() : _json = {};

  _JsonObject.fromJson(Map<String, Object?> json) : _json = json;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _JsonObject && mapEquals(other._json, _json);

  @override
  int get hashCode => _json.hashCode;

  dynamic toJson() {
    Map<String, Object> result = {};
    _json.forEach((k, v) => {if (v != null) result[k] = v});
    return result;
  }
}
