import '_model_extensions.dart';

/// Information about the current user of your application.
class BugsnagUser {
  String? id;
  String? email;
  String? name;

  BugsnagUser({this.id, this.email, this.name});

  BugsnagUser.fromJson(Map<String, dynamic> json)
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
      other is BugsnagUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, email, name);
}
