import 'user.dart';

/// Represents a contiguous session in an application.
class BugsnagSession {
  String id;
  DateTime startedAt;
  BugsnagUser user;

  BugsnagSession.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        startedAt = DateTime.parse(json['startedAt']).toUtc(),
        user = BugsnagUser.fromJson(json['user'] as Map<String, dynamic>);

  dynamic toJson() => {
        'id': id,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'user': user,
      };
}
