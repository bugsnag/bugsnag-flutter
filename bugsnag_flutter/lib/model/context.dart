/// Information about the current user of your application.
class User {
  final String? id;
  final String? email;
  final String? name;

  const User({this.id, this.email, this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;

  @override
  String toString() => 'User{id: $id, email: $email, name: $name}';

  dynamic toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  static User fromJson(Map<String, Object?> json) => User(
        id: json['id'] as String?,
        email: json['email'] as String?,
        name: json['name'] as String?,
      );
}

class FeatureFlag {
  final String name;
  final String? variant;

  const FeatureFlag(this.name, [this.variant]);

  dynamic toJson() => {
        'featureFlag': name,
        if (variant != null) 'variant': variant,
      };

  @override
  String toString() => "FeatureFlag{name: $name, variant: $variant}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureFlag &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          variant == other.variant;

  @override
  int get hashCode => name.hashCode ^ variant.hashCode;
}

class Session {}

class Breadcrumb {}
