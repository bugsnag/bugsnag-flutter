import 'dart:io';

import '_model_extensions.dart';
import 'event.dart';
import 'stackframe.dart';

/// A representation of a native thread recorded in an [BugsnagEvent]. These
/// typically map to native iOS and Android threads.
class BugsnagThread {
  /// The unique ID of the thread
  String? id;

  /// The name of the thread
  String? name;

  /// The status of the thread
  String? state;

  /// Whether the thread was the thread that caused the event
  bool isErrorReportingThread;

  /// The type of thread based on the originating platform (intended for
  /// internal use only)
  BugsnagErrorType type;

  final BugsnagStacktrace _stacktrace;

  /// A representation of the thread's stacktrace
  BugsnagStacktrace get stacktrace => _stacktrace;

  BugsnagThread({
    this.id,
    this.name,
    this.state,
    bool? isErrorReportingThread,
    this.type = BugsnagErrorType.dart,
    required BugsnagStacktrace stacktrace,
  })  : _stacktrace = stacktrace,
        isErrorReportingThread = isErrorReportingThread == true;

  BugsnagThread.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString(),
        name = json.safeGet('name'),
        state = json.safeGet('state'),
        isErrorReportingThread = json.safeGet('errorReportingThread') == true,
        type = json
                .safeGet<String>('type')
                ?.let((name) => BugsnagErrorType.forName(name)) ??
            (Platform.isAndroid
                ? BugsnagErrorType.android
                : BugsnagErrorType.cocoa),
        _stacktrace = json.safeGet<List>('stacktrace')?.let((frames) =>
                BugsnagStackframe.stacktraceFromJson(frames.cast())) ??
            [];

  dynamic toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (state != null) 'state': state,
        if (isErrorReportingThread) 'errorReportingThread': true,
        'type': type.name,
        'stacktrace': _stacktrace,
      };
}
