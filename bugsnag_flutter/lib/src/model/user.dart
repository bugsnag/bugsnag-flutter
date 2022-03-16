part of model;

/// Information about the current user of your application.
class User {
  String? id;
  String? email;
  String? name;

  User({this.id, this.email, this.name});

  User.fromJson(Map<String, dynamic> json)
      : id = json.safeGet('id'),
        email = json.safeGet('email'),
        name = json.safeGet('name');

  dynamic toJson() => {
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, email, name);
}
