import 'dart:io';

import '../enum_utils.dart';
import '_model_extensions.dart';
import 'app.dart';
import 'breadcrumbs.dart';
import 'device.dart';
import 'feature_flags.dart';
import 'metadata.dart';
import 'stackframe.dart';
import 'thread.dart';
import 'user.dart';

/// An Event object represents an error captured by Bugsnag and is available
/// as a parameter on [OnErrorCallback], where individual properties can be
/// mutated before an error report is sent to Bugsnag's API.
class BugsnagEvent {
  BugsnagUser _user;
  bool _unhandled;
  final bool _originalUnhandled;
  final _SeverityReason _severityReason;
  final List<String> _projectPackages;
  final _Session? _session;
  final BugsnagFeatureFlags _featureFlags;
  final BugsnagMetadata _metadata;

  String? apiKey;

  /// Information extracted from the errors that caused the event can be found
  /// in this field. The list contains at least one `BugsnagError` that
  /// represents the thrown object.
  List<BugsnagError> errors;

  /// If thread state is being captured along with the event, this field will
  /// contain a list of [BugsnagThread] objects representing the native threads
  /// that were active when the error was captured.
  List<BugsnagThread> threads;

  /// A list of breadcrumbs leading up to the event. These values can be
  /// accessed and amended if necessary.
  List<BugsnagBreadcrumb> breadcrumbs;

  /// The context of the error. The context is a summary of what was occurring
  /// in the application at the time of the crash, if available, such as the
  /// visible page or screen.
  String? context;

  /// A tie-breaker used to discriminate events that would otherwise group.
  /// If set on the Event, it takes priority over the global value.
  String? groupingDiscriminator;

  /// The grouping hash of the event to override the default grouping on the
  /// dashboard. All events with the same grouping hash will be grouped together
  /// into one error. This is an advanced usage of the library and mis-using it
  /// will cause your events not to group properly in your dashboard.
  ///
  /// As the name implies, this option accepts a hash of sorts.
  String? groupingHash;

  /// The severity of the event. By default, unhandled exceptions will be
  /// [BugsnagSeverity.error] and handled exceptions sent with [Client.notify]
  /// [BugsnagSeverity.warning].
  BugsnagSeverity severity;

  /// Information set by the notifier about your device can be found in this
  /// field. These values can be accessed and amended if necessary.
  BugsnagDeviceWithState device;

  /// Information set by the notifier about your app can be found in this field.
  /// These values can be accessed and amended if necessary.
  BugsnagAppWithState app;

  /// Whether the event was a crash (i.e. unhandled) or handled error in which
  /// the system continued running.
  ///
  /// Unhandled errors count towards your stability score. If you don't want
  /// certain errors to count towards your stability score, you can alter this
  /// property through a [BugsnagOnErrorCallback]
  bool get unhandled => _unhandled;

  /// The User information associated with this event
  BugsnagUser get user => _user;

  set unhandled(bool unhandled) {
    _unhandled = unhandled;
    _severityReason.unhandledOverridden =
        (_unhandled != _originalUnhandled) ? true : null;
  }

  /// Adds a map of multiple metadata key-value pairs to the specified section.
  void addMetadata(String section, Map<String, Object> metadata) =>
      _metadata.addMetadata(section, metadata);

  /// If [key] is not `null`: removes data with the specified key from the
  /// specified section. Otherwise remove all the data from the specified
  /// [section].
  void clearMetadata(String section, [String? key]) =>
      _metadata.clearMetadata(section, key);

  /// Returns a map of data in the specified section.
  Map<String, Object>? getMetadata(String section) =>
      _metadata.getMetadata(section);

  /// Add a single feature flag with an optional variant. If there is an
  /// existing feature flag with the same name, it will be overwritten with the
  /// new variant.
  ///
  /// See also:
  /// - [addFeatureFlags]
  /// - [clearFeatureFlag]
  /// - [clearFeatureFlags]
  void addFeatureFlag(String name, [String? variant]) =>
      _featureFlags.addFeatureFlag(name, variant);

  /// Remove a single feature flag regardless of its current status. This will
  /// stop the specified feature flag from being reported. If the named feature
  /// flag does not exist this will have no effect.
  ///
  /// See also:
  /// - [addFeatureFlag]
  /// - [addFeatureFlags]
  /// - [clearFeatureFlags]
  void clearFeatureFlag(String name) => _featureFlags.clearFeatureFlag(name);

  /// Clear all of the feature flags. This will stop all feature flags from
  /// being reported.
  ///
  /// See also:
  /// - [addFeatureFlag]
  /// - [addFeatureFlags]
  /// - [clearFeatureFlag]
  void clearFeatureFlags() => _featureFlags.clearFeatureFlags();

  /// Sets the user associated with the event.
  void setUser({String? id, String? email, String? name}) {
    _user = BugsnagUser(id: id, email: email, name: name);
  }

  BugsnagEvent.fromJson(Map<String, dynamic> json)
      : apiKey = json['apiKey'] as String?,
        errors = (json['exceptions'] as List?)
                ?.cast<Map>()
                .map((m) => BugsnagError.fromJson(m.cast()))
                .toList(growable: true) ??
            [],
        threads = (json['threads'] as List?)
                ?.cast<Map>()
                .map((m) => BugsnagThread.fromJson(m.cast()))
                .toList(growable: true) ??
            [],
        breadcrumbs = (json['breadcrumbs'] as List?)
                ?.cast<Map>()
                .map((m) => BugsnagBreadcrumb.fromJson(m.cast()))
                .toList(growable: true) ??
            [],
        context = json['context'] as String?,
        groupingHash = json['groupingHash'] as String?,
        groupingDiscriminator = json['groupingDiscriminator'] as String?,
        _unhandled = json['unhandled'] == true,
        _originalUnhandled = json['unhandled'] == true,
        severity = BugsnagSeverity.values.findByName(json['severity']),
        _severityReason = _SeverityReason.fromJson(json['severityReason']),
        _projectPackages =
            (json['projectPackages'] as List?)?.toList(growable: true).cast() ??
                [],
        _session = json
            .safeGet<Map>('session')
            ?.let((session) => _Session.fromJson(session.cast())),
        _user = BugsnagUser.fromJson(json['user']),
        device = BugsnagDeviceWithState.fromJson(json['device']),
        app = BugsnagAppWithState.fromJson(json['app']),
        _featureFlags = BugsnagFeatureFlags.fromJson(
            json['featureFlags'].cast<Map<String, dynamic>>()),
        _metadata = json
                .safeGet<Map>('metaData')
                ?.let((m) => BugsnagMetadata.fromJson(m.cast())) ??
            BugsnagMetadata();

  dynamic toJson() {
    return {
      if (apiKey != null) 'apiKey': apiKey,
      'exceptions': errors,
      'threads': threads,
      'breadcrumbs': breadcrumbs,
      if (context != null) 'context': context,
      if (groupingHash != null) 'groupingHash': groupingHash,
      if (groupingDiscriminator != null) 'groupingDiscriminator': groupingDiscriminator,
      'unhandled': unhandled,
      'severity': severity.toName(),
      'severityReason': _severityReason,
      'projectPackages': _projectPackages,
      'user': user,
      if (_session != null) 'session': _session,
      'device': device,
      'app': app,
      'featureFlags': _featureFlags,
      'metaData': _metadata,
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
        startedAt = DateTime.parse(json['startedAt'] as String).toUtc(),
        handledCount =
            (json['events'] as Map?)?.safeGet<num>('handled')?.toInt() ?? 0,
        unhandledCount =
            (json['events'] as Map?)?.safeGet<num>('unhandled')?.toInt() ?? 0;

  dynamic toJson() => {
        'id': id,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'events': {
          'handled': handledCount,
          'unhandled': unhandledCount,
        }
      };
}

/// The severity of a [BugsnagEvent], one of [error], [warning] or [info].
enum BugsnagSeverity {
  error,
  warning,
  info,
}

/// A [BugsnagError] represents information extracted from an error.
class BugsnagError {
  /// The class name of the object thrown.
  String errorClass;

  /// The message string extracted from the thrown error.
  String? message;

  /// The type of error based on the originating platform (intended for internal use only)
  BugsnagErrorType type;

  /// A representation of the stacktrace
  BugsnagStacktrace stacktrace;

  BugsnagError(this.errorClass, this.message, this.stacktrace)
      : type = BugsnagErrorType.dart;

  BugsnagError.fromJson(Map<String, dynamic> json)
      : errorClass = json.safeGet('errorClass'),
        message = json.safeGet('message'),
        type = json
                .safeGet<String>('type')
                ?.let((type) => BugsnagErrorType.forName(type)) ??
            (Platform.isAndroid
                ? BugsnagErrorType.android
                : BugsnagErrorType.cocoa),
        stacktrace = BugsnagStackframe.stacktraceFromJson(
            (json['stacktrace'] as List).cast());

  dynamic toJson() => {
        'errorClass': errorClass,
        if (message != null) 'message': message,
        'type': type.name,
        'stacktrace': stacktrace,
      };
}

/// Represents the type of error captured (intended for internal use only)
class BugsnagErrorType {
  /// An error captured from Android's JVM layer
  static const android = BugsnagErrorType._create('android');

  /// An error captured from iOS
  static const cocoa = BugsnagErrorType._create('cocoa');

  /// An error captured from Android's C layer
  static const c = BugsnagErrorType._create('c');

  /// An error captured from Dart
  static const dart = BugsnagErrorType._create('dart');

  final String name;

  const BugsnagErrorType._create(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BugsnagErrorType &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;

  factory BugsnagErrorType.forName(String name) {
    if (name == android.name) return android;
    if (name == cocoa.name) return cocoa;
    if (name == c.name) return c;
    if (name == dart.name) return dart;

    return BugsnagErrorType._create(name);
  }
}
