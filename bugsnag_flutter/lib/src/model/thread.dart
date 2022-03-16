part of model;

class Thread extends _JsonObject {
  Thread.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  String? get id => _json['id'] as String?;

  set id(String? id) => _json['id'] = id;

  String? get name => _json['name'] as String?;

  set name(String? name) => _json['name'] = name;

  bool get isErrorReportingThread => _json['errorReportingThread'] == true;

  ThreadType get type => ThreadType(_json['type'] as String);

  set type(ThreadType type) => _json['type'] = type.name;

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
