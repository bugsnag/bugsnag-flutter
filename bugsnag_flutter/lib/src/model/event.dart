import 'dart:io';

import '_model_extensions.dart';
import 'app.dart';
import 'breadcrumbs.dart';
import 'device.dart';
import 'feature_flags.dart';
import 'metadata.dart';
import 'stackframe.dart';
import 'thread.dart';
import 'user.dart';

class Event {
  String? apiKey;
  List<Error> errors;
  List<Thread> threads;
  List<Breadcrumb> breadcrumbs;
  String? context;
  String? groupingHash;
  bool _unhandled;
  final bool _originalUnhandled;
  Severity severity;
  final _SeverityReason _severityReason;
  final List<String> _projectPackages;
  User user;
  final _Session? _session;

  DeviceWithState device;
  AppWithState app;

  FeatureFlags featureFlags;
  Metadata metadata;

  bool get unhandled => _unhandled;

  set unhandled(bool unhandled) {
    _unhandled = unhandled;
    _severityReason.unhandledOverridden =
        (_unhandled != _originalUnhandled) ? true : null;
  }

  Event.fromJson(Map<String, dynamic> json)
      : apiKey = json['apiKey'] as String?,
        errors = (json['exceptions'] as List?)
                ?.cast<Map>()
                .map((m) => Error.fromJson(m.cast()))
                .toList(growable: true) ??
            [],
        threads = (json['threads'] as List?)
                ?.cast<Map>()
                .map((m) => Thread.fromJson(m.cast()))
                .toList(growable: true) ??
            [],
        breadcrumbs = (json['breadcrumbs'] as List?)
                ?.cast<Map>()
                .map((m) => Breadcrumb.fromJson(m.cast()))
                .toList(growable: true) ??
            [],
        context = json['context'] as String?,
        groupingHash = json['groupingHash'] as String?,
        _unhandled = json['unhandled'] == true,
        _originalUnhandled = json['unhandled'] == true,
        severity = Severity.values.byName(json['severity']),
        _severityReason = _SeverityReason.fromJson(json['severityReason']),
        _projectPackages =
            (json['projectPackages'] as List?)?.toList(growable: true).cast() ??
                [],
        user = User.fromJson(json['user']),
        _session = json
            .safeGet<Map>('session')
            ?.let((session) => _Session.fromJson(session.cast())),
        device = DeviceWithState.fromJson(json['device']),
        app = AppWithState.fromJson(json['app']),
        featureFlags = FeatureFlags.fromJson(
            json['featureFlags'].cast<Map<String, dynamic>>()),
        metadata = json
                .safeGet<Map>('metaData')
                ?.let((m) => Metadata.fromJson(m.cast())) ??
            Metadata();

  dynamic toJson() {
    return {
      if (apiKey != null) 'apiKey': apiKey,
      'exceptions': errors,
      'threads': threads,
      'breadcrumbs': breadcrumbs,
      if (context != null) 'context': context,
      if (groupingHash != null) 'groupingHash': groupingHash,
      'unhandled': unhandled,
      'severity': severity.name,
      'severityReason': _severityReason,
      'projectPackages': _projectPackages,
      'user': user,
      if (_session != null) 'session': _session,
      'device': device,
      'app': app,
      'featureFlags': featureFlags,
      'metaData': metadata,
    };
  }
}

class _SeverityReason {
  String type;
  bool? unhandledOverridden;

  _SeverityReason.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        unhandledOverridden = json.safeGet('unhandledOverridden');

  dynamic toJson() => {
        'type': type,
        if (unhandledOverridden != null)
          'unhandledOverridden': unhandledOverridden,
      };
}

class _Session {
  String id;

  int handledCount;
  int unhandledCount;

  DateTime startedAt;

  _Session.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        startedAt = DateTime.parse(json['startedAt'] as String),
        handledCount =
            (json['events'] as Map?)?.safeGet<num>('handled')?.toInt() ?? 0,
        unhandledCount =
            (json['events'] as Map?)?.safeGet<num>('unhandled')?.toInt() ?? 0;

  dynamic toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'events': {
          'handled': handledCount,
          'unhandled': unhandledCount,
        }
      };
}

enum Severity {
  error,
  warning,
  info,
}

class Error {
  String errorClass;
  String? message;
  ErrorType type;

  Stacktrace stacktrace;

  Error(this.errorClass, this.message, this.stacktrace) : type = ErrorType.dart;

  Error.fromJson(Map<String, dynamic> json)
      : errorClass = json.safeGet('errorClass'),
        message = json.safeGet('message'),
        type = json.safeGet<String>('type')?.let(ErrorType.forName) ??
            (Platform.isAndroid ? ErrorType.android : ErrorType.cocoa),
        stacktrace =
            Stackframe.stacktraceFromJson((json['stacktrace'] as List).cast());

  dynamic toJson() => {
        'errorClass': errorClass,
        if (message != null) 'message': message,
        'type': type.name,
        'stacktrace': stacktrace,
      };
}

class ErrorType {
  static const android = ErrorType._create('android');
  static const cocoa = ErrorType._create('cocoa');
  static const c = ErrorType._create('c');
  static const dart = ErrorType._create('dart');

  final String name;

  const ErrorType._create(this.name);

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

  factory ErrorType.forName(String name) {
    if (name == android.name) return android;
    if (name == cocoa.name) return cocoa;
    if (name == c.name) return c;
    if (name == dart.name) return dart;

    return ErrorType._create(name);
  }
}
