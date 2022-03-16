part of model;

class Stackframe extends _JsonObject {
  Stackframe.fromJson(Map<String, Object?> json) : super.fromJson(json);

  Stackframe.fromStackFrame(StackFrame frame)
      : super.fromJson({
          'type': 'flutter',
          'file': frame.packagePath,
          'lineNumber': frame.line,
          'columnNumber': frame.column,
          'method': frame.method
        });

  String? get type => _json['type'] as String?;

  set type(String? value) => _json['type'] = value;

  String? get file => _json['file'] as String?;

  set file(String? value) => _json['file'] = value;

  int? get lineNumber => _json['lineNumber'] as int?;

  set lineNumber(int? value) => _json['lineNumber'] = value;

  int? get columnNumber => _json['columnNumber'] as int?;

  set columnNumber(int? value) => _json['columnNumber'] = value;

  String? get method => _json['method'] as String?;

  set method(String? value) => _json['method'] = value;

  Map<String, String>? get code => _json['code'] as Map<String, String>?;

  set code(Map<String, String>? value) => _json['code'] = value;

  bool? get inProject => _json['inProject'] as bool?;

  set inProject(bool? value) => _json['inProject'] = value;

  String? get frameAddress => _getAddress('frameAddress');

  set frameAddress(String? value) => _json['frameAddress'] = value;

  String? get loadAddress => _getAddress('loadAddress');

  set loadAddress(String? value) => _json['loadAddress'] = value;

  bool? get isLR => _json['isLR'] as bool?;

  set isLR(bool? value) => _json['isLR'] = value;

  bool? get isPC => _json['isPC'] as bool?;

  set isPC(bool? value) => _json['isPC'] = value;

  String? get symbolAddress => _getAddress('symbolAddress');

  set symbolAddress(String? value) => _json['symbolAddress'] = value;

  String? get machoFile => _json['machoFile'] as String?;

  set machoFile(String? value) => _json['machoFile'] = value;

  String? get machoLoadAddress => _json['machoLoadAddress'] as String?;

  set machoLoadAddress(String? value) => _json['machoLoadAddress'] = value;

  String? get machoUUID => _json['machoUUID'] as String?;

  set machoUUID(String? value) => _json['machoUUID'] = value;

  String? get machoVMAddress => _json['machoVMAddress'] as String?;

  set machoVMAddress(String? value) => _json['machoVMAddress'] = value;

  // Required on platforms (e.g. Android) which include numeric rather than the
  // expected string values for memory addresses.
  String? _getAddress(String key) {
    final value = _json[key];
    if (value is String) return value;
    if (value is int) return '0x' + value.toRadixString(16);
    return null;
  }
}

class Stacktrace extends ListBase<Stackframe> {
  final List<Stackframe> _delegate;

  Stacktrace(this._delegate);

  Stacktrace.fromStackTrace(StackTrace stackTrace)
      : this(StackFrame.fromStackTrace(stackTrace)
            .map(Stackframe.fromStackFrame)
            .toList());

  Stacktrace.fromJson(List<Map<String, dynamic>> json)
      : this(json.map(Stackframe.fromJson).toList());

  @override
  int get length => _delegate.length;

  @override
  set length(int length) => _delegate.length = length;

  @override
  Stackframe operator [](int index) => _delegate[index];

  @override
  void operator []=(int index, Stackframe value) => _delegate[index] = value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stacktrace &&
          runtimeType == other.runtimeType &&
          _delegate.deepEquals(other._delegate);

  @override
  int get hashCode => _delegate.fold(0, (h, element) => h ^ element.hashCode);

  dynamic toJson() => _delegate.map((frame) => frame.toJson()).toList();
}
