import 'dart:io';

import '_model_extensions.dart';
import 'event.dart';
import 'stackframe.dart';

class BugsnagThread {
  String? id;
  String? name;
  String? state;
  bool isErrorReportingThread;
  BugsnagErrorType type;

  final BugsnagStacktrace _stacktrace;

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
        type = json.safeGet<String>('type')?.let(BugsnagErrorType.forName) ??
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
