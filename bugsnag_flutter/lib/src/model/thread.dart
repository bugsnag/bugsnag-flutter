import 'dart:io';

import '_model_extensions.dart';
import 'event.dart';
import 'stackframe.dart';

class Thread {
  String? id;
  String? name;
  String? state;
  bool isErrorReportingThread;
  ErrorType type;

  final Stacktrace _stacktrace;

  Stacktrace get stacktrace => _stacktrace;

  Thread({
    this.id,
    this.name,
    this.state,
    bool? isErrorReportingThread,
    this.type = ErrorType.flutter,
    required Stacktrace stacktrace,
  })  : _stacktrace = stacktrace,
        isErrorReportingThread = isErrorReportingThread == true;

  Thread.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString(),
        name = json.safeGet('name'),
        state = json.safeGet('state'),
        isErrorReportingThread = json.safeGet('errorReportingThread') == true,
        type = json.safeGet<String>('type')?.let(ErrorType.forName) ??
            (Platform.isAndroid ? ErrorType.android : ErrorType.cocoa),
        _stacktrace = json.safeGet<List>('stacktrace')?.let(
                (frames) => Stackframe.stacktraceFromJson(frames.cast())) ??
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
