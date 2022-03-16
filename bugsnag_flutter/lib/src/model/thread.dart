part of model;

class Thread {
  String? id;
  String? name;
  String? state;
  bool isErrorReportingThread;
  ThreadType type;

  final Stacktrace _stacktrace;

  Stacktrace get stacktrace => _stacktrace;

  Thread.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString(),
        name = json.safeGet('name'),
        state = json.safeGet('state'),
        isErrorReportingThread = json.safeGet('errorReportingThread') == true,
        type = json.safeGet<String>('type')?.let(ThreadType.new) ??
            (Platform.isAndroid ? ThreadType.android : ThreadType.cocoa),
        _stacktrace = json
                .safeGet<List>('stacktrace')
                ?.let((frames) => Stacktrace.fromJson(frames.cast())) ??
            Stacktrace([]);

  dynamic toJson() =>
      {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (state != null) 'state': state,
        if (isErrorReportingThread) 'errorReportingThread': true,
        'type': type.name,
        'stacktrace': _stacktrace,
      };
}

class ThreadType {
  /// Android Only: A Thread captured from within the Android Runtime (ART)
  static const android = ThreadType('android');

  /// Android Only: A Thread captured from the NDK layer
  static const c = ThreadType('c');

  /// iOS & Android: A thread captured from a ReactNative application
  static const reactnativejs = ThreadType('reactnativejs');

  /// iOS Only: A thread captured from an iOS native application
  static const cocoa = ThreadType('cocoa');

  final String name;

  const ThreadType(this.name);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreadType &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
