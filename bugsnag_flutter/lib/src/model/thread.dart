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

  Thread.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString(),
        name = json.safeGet('name'),
        state = json.safeGet('state'),
        isErrorReportingThread = json.safeGet('errorReportingThread') == true,
        type = json.safeGet<String>('type')?.let(ErrorType.forName) ??
            (Platform.isAndroid ? ErrorType.android : ErrorType.cocoa),
        _stacktrace = json
                .safeGet<List>('stacktrace')
                ?.let((frames) => Stacktrace.fromJson(frames.cast())) ??
            Stacktrace([]);

  dynamic toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (state != null) 'state': state,
        if (isErrorReportingThread) 'errorReportingThread': true,
        'type': type.name,
        'stacktrace': _stacktrace,
      };
}
