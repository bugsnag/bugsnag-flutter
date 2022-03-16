part of model;

/// Information about the current user of your application.
class User extends _JsonObject {
  User({String? id, String? email, String? name}) {
    this.id = id;
    this.email = email;
    this.name = name;
  }

  User.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  String? get id => _json['id'] as String?;

  set id(String? id) => _json['id'] = id;

  String? get email => _json['email'] as String?;

  set email(String? email) => _json['email'] = email;

  String? get name => _json['name'] as String?;

  set name(String? name) => _json['name'] = name;
}
