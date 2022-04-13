import 'user.dart';

class BugsnagSession {
  String id;
  DateTime startedAt;
  User user;

  BugsnagSession.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        startedAt = DateTime.parse(json['startedAt']),
        user = User.fromJson(json['user'] as Map<String, dynamic>);

  dynamic toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'user': user,
      };
}
