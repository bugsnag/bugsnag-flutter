part of model;

class Event {
  String? apiKey;
  List<Error> errors;
  List<Thread> threads;
  List<Breadcrumb> breadcrumbs;
  String? context;
  String? groupingHash;
  bool unhandled;
  final bool _originalUnhandled;
  Severity _severity;
  _SeverityReason _severityReason;
  List<String> _projectPackages;
  User user;
  Session? session;

  DeviceWithState device;
  AppWithState app;

  FeatureFlags featureFlags;
  Metadata metadata;

  Event.fromJson(Map<String, dynamic> json)
      : apiKey = json['apiKey'] as String?,
        errors = (json['exceptions'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(Error.fromJson)
                .toList(growable: true) ??
            [],
        threads = (json['threads'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(Thread.fromJson)
                .toList(growable: true) ??
            [],
        breadcrumbs = (json['breadcrumbs'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(Breadcrumb.fromJson)
                .toList(growable: true) ??
            [],
        context = json['context'] as String?,
        groupingHash = json['groupingHash'] as String?,
        unhandled = json['unhandled'] == true,
        _originalUnhandled = json['unhandled'] == true,
        _severity = Severity.values.byName(json['severity']),
        _severityReason = _SeverityReason.fromJson(json['severityReason']),
        _projectPackages =
            (json['projectPackages'] as List?)?.toList(growable: true).cast() ??
                [],
        user = User.fromJson(json['user']),
        session = json
            .safeGet<Map<String, dynamic>>('session')
            ?.let((session) => Session.fromJson(session)),
        device = DeviceWithState.fromJson(json['device']),
        app = AppWithState.fromJson(json['app']),
        featureFlags = FeatureFlags.fromJson(
            json['featureFlags'].cast<Map<String, dynamic>>()),
        metadata = Metadata.fromJson(json['metaData'] as Map<String, dynamic>);

  dynamic toJson() {
    if (unhandled != _originalUnhandled) {
      _severityReason.unhandledOverridden = true;
    }

    return {
      if (apiKey != null) 'apiKey': apiKey,
      'exceptions': errors,
      'threads': threads,
      'breadcrumbs': breadcrumbs,
      if (context != null) 'context': context,
      if (groupingHash != null) 'groupingHash': groupingHash,
      'unhandled': unhandled,
      'severity': _severity.name,
      'severityReason': _severityReason,
      'projectPackages': _projectPackages,
      'user': user,
      if (session != null) 'session': session,
      'device': device,
      'app': app,
      'featureFlags': featureFlags,
      'metaData': metadata,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey &&
          errors.deepEquals(other.errors) &&
          threads.deepEquals(other.threads) &&
          breadcrumbs.deepEquals(other.breadcrumbs) &&
          context == other.context &&
          groupingHash == other.groupingHash &&
          unhandled == other.unhandled &&
          _severityReason == other._severityReason &&
          _projectPackages.deepEquals(other._projectPackages) &&
          user == other.user &&
          session == other.session &&
          device == other.device &&
          app == other.app &&
          featureFlags == other.featureFlags &&
          metadata == other.metadata;

  @override
  int get hashCode => Object.hash(
        apiKey.hashCode,
        errors.hashCode,
        threads.hashCode,
        breadcrumbs.hashCode,
        context.hashCode,
        groupingHash.hashCode,
        unhandled.hashCode,
        _severityReason.hashCode,
        _projectPackages.hashCode,
        user.hashCode,
        session.hashCode,
        device.hashCode,
        app.hashCode,
        featureFlags.hashCode,
        metadata.hashCode,
      );
}

class _SeverityReason extends _JsonObject {
  String get type => _json['type'] as String;

  set type(String type) => _json['type'] = type;

  bool? get unhandledOverridden => _json['unhandledOverridden'] as bool?;

  set unhandledOverridden(bool? unhandledOverridden) =>
      _json['unhandledOverridden'] = unhandledOverridden;

  _SeverityReason.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

enum Severity {
  error,
  warning,
  info,
}

class Error extends _JsonObject {
  Error.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  String get errorClass => _json['errorClass'] as String;

  set errorClass(String errorClass) => _json['errorClass'] = errorClass;

  String? get message => _json['message'] as String?;

  set message(String? message) => _json['message'] = message;

  ErrorType get type => ErrorType(_json['type'] as String);

  set type(ErrorType errorType) => _json['type'] = errorType.name;

  Stacktrace get stacktrace {
    final st = _json['stacktrace'];

    if (st is List<Map<String, dynamic>>) {
      return Stacktrace.fromJson(st);
    } else {
      final frames = <Stackframe>[];
      _json['stacktrace'] = frames;
      return Stacktrace(frames);
    }
  }

  set stacktrace(Stacktrace stacktrace) =>
      _json['stacktrace'] = stacktrace.toJson();
}

class ErrorType {
  static const android = ErrorType('android');
  static const c = ErrorType('c');
  static const cocoa = ErrorType('cocoa');
  static const flutter = ErrorType('flutter');

  final String name;

  const ErrorType(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorType &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
