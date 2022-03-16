part of model;

class Session {
  String id;
  DateTime startedAt;
  User user;
  App app;
  Device device;
  Notifier notifier;

  Session.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        startedAt = DateTime.parse(json['startedAt']),
        user = User.fromJson(json['user'] as Map<String, dynamic>),
        app = App.fromJson(json['app'] as Map<String, dynamic>),
        device = Device.fromJson(json['device'] as Map<String, dynamic>),
        notifier = Notifier.fromJson(json['notifier'] as Map<String, dynamic>);

  dynamic toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'user': user,
        'app': app,
        'device': device,
        'notifier': notifier,
      };
}
