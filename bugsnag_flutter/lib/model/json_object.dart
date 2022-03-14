part of bugsnag;

class JsonObject {
  final Map<String, Object?> _json;

  JsonObject() : _json = {};

  JsonObject.fromJson(Map<String, Object?> json) : _json = json;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonObject && mapEquals(other._json, _json);

  @override
  int get hashCode => _json.hashCode;

  dynamic toJson() {
    Map<String, Object> result = {};
    _json.forEach((k, v) => {if (v != null) result[k] = v});
    return result;
  }
}
