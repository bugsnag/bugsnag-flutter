import 'dart:collection';

import 'package:flutter/foundation.dart';

import '_model_extensions.dart';
import 'event.dart';

class Stackframe {
  ErrorType? type;
  String? file;
  int? lineNumber;
  int? columnNumber;
  String? method;
  Map<String, String>? code;
  bool? inProject;
  String? frameAddress;
  String? loadAddress;
  bool? isLR;
  bool? isPC;
  String? symbolAddress;
  String? machoFile;
  String? machoLoadAddress;
  String? machoUUID;
  String? machoVMAddress;

  Stackframe.fromJson(Map<String, Object?> json)
      : type = json.safeGet<String>('type')?.let(ErrorType.forName),
        file = json.safeGet('file'),
        lineNumber = json.safeGet<num>('lineNumber')?.toInt(),
        columnNumber = json.safeGet<num>('columnNumber')?.toInt(),
        method = json.safeGet('method'),
        code = json
            .safeGet<Map>('code')
            ?.map((key, value) => MapEntry(key as String, value as String)),
        inProject = json.safeGet('inProject'),
        frameAddress = _getAddress(json['frameAddress']),
        loadAddress = _getAddress(json['loadAddress']),
        isLR = json.safeGet('isLR'),
        isPC = json.safeGet('isPC'),
        symbolAddress = _getAddress(json['symbolAddress']),
        machoFile = json.safeGet('machoFile'),
        machoLoadAddress = json.safeGet('machoLoadAddress'),
        machoUUID = json.safeGet('machoUUID'),
        machoVMAddress = json.safeGet('machoVMAddress');

  Stackframe.fromStackFrame(StackFrame frame)
      : type = ErrorType.flutter,
        file = frame.packagePath,
        lineNumber = frame.line,
        columnNumber = frame.column,
        method = frame.method;

  dynamic toJson() => {
        if (type != null) 'type': type!.name,
        if (file != null) 'file': file,
        if (lineNumber != null) 'lineNumber': lineNumber,
        if (columnNumber != null) 'columnNumber': columnNumber,
        if (method != null) 'method': method,
        if (code != null) 'code': code,
        if (inProject != null) 'inProject': inProject,
        if (frameAddress != null) 'frameAddress': _addressValue(frameAddress),
        if (loadAddress != null) 'loadAddress': _addressValue(loadAddress),
        if (isLR != null) 'isLR': isLR,
        if (isPC != null) 'isPC': isPC,
        if (symbolAddress != null)
          'symbolAddress': _addressValue(symbolAddress),
        if (machoFile != null) 'machoFile': machoFile,
        if (machoLoadAddress != null) 'machoLoadAddress': machoLoadAddress,
        if (machoUUID != null) 'machoUUID': machoUUID,
        if (machoVMAddress != null) 'machoVMAddress': machoVMAddress,
      };

  dynamic _addressValue(String? address) {
    if (address == null) {
      return null;
    } else if (type == ErrorType.android ||
        type == ErrorType.c && address.startsWith('0x')) {
      return int.parse(address.substring(2), radix: 16);
    } else {
      return address;
    }
  }

  // Required on platforms (e.g. Android) which include numeric rather than the
  // expected string values for memory addresses.
  static String? _getAddress(dynamic value) {
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
