part of model;

class Session extends _JsonObject {
  Session(String id, DateTime startedAt, User user)
      : super.fromJson({
          'id': id,
          'startedAt': startedAt.toIso8601String(),
          'user': user.toJson(),
        });

  Session.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  String get id => _json['id'] as String;

  set id(String id) => _json['id'] = id;

  DateTime get startedAt => DateTime.parse(_json['startedAt'] as String);

  set startedAt(DateTime startedAt) =>
      _json['startedAt'] = startedAt.toIso8601String();

  User? get user =>
      _json.safeGet<Map<String, dynamic>>('user')?.let(User.fromJson);

  set user(User? user) => _json['user'] = user?.toJson();

  App get app => App.fromJson(_json['app'] as Map<String, dynamic>);

  set app(App app) => _json['app'] = app.toJson();

  Device get device => Device.fromJson(_json['device'] as Map<String, dynamic>);

  set device(Device device) => _json['device'] = device.toJson();
}
