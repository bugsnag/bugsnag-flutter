import 'package:flutter/foundation.dart';

class StackElement {
  String? method;
  String? file;
  int? lineNumber;
  bool? inProject;

  Map<String, String>? code;
  int? columnNumber;

  int? frameAddress;
  int? symbolAddress;
  int? loadAddress;
  bool? isPC;

  ErrorType? type;

  StackElement({
    this.method,
    this.file,
    this.lineNumber,
    this.inProject,
    this.code,
    this.columnNumber,
    this.frameAddress,
    this.symbolAddress,
    this.loadAddress,
    this.isPC,
    this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StackElement &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          file == other.file &&
          lineNumber == other.lineNumber &&
          inProject == other.inProject &&
          mapEquals(code, other.code) &&
          columnNumber == other.columnNumber &&
          frameAddress == other.frameAddress &&
          symbolAddress == other.symbolAddress &&
          loadAddress == other.loadAddress &&
          isPC == other.isPC &&
          type == other.type;

  @override
  int get hashCode =>
      method.hashCode ^
      file.hashCode ^
      lineNumber.hashCode ^
      inProject.hashCode ^
      code.hashCode ^
      columnNumber.hashCode ^
      frameAddress.hashCode ^
      symbolAddress.hashCode ^
      loadAddress.hashCode ^
      isPC.hashCode ^
      type.hashCode;

  dynamic toJson() => {
        'method': method,
        'file': file,
        'lineNumber': lineNumber,
        if (inProject != null) 'inProject': inProject,
        'columnNumber': columnNumber,
        if (frameAddress != null) 'frameAddress': frameAddress,
        if (symbolAddress != null) 'symbolAddress': symbolAddress,
        if (loadAddress != null) 'loadAddress': loadAddress,
        if (isPC != null) 'isPC': isPC,
        if (type != null) 'type': type?.name,
        if (code != null) 'code': code,
      };

  static StackElement fromJson(Map<String, Object?> json) => StackElement(
        method: json['method'] as String?,
        file: json['file'] as String?,
        lineNumber: json['lineNumber'] as int?,
        inProject: json['inProject'] as bool?,
        columnNumber: json['columnNumber'] as int?,
        frameAddress: json['frameAddress'] as int?,
        symbolAddress: json['symbolAddress'] as int?,
        loadAddress: json['loadAddress'] as int?,
        isPC: json['isPC'] as bool?,
        type: errorTypeByName(json['type'] as String?),
        code: json['code'] as Map<String, String>?,
      );
}

enum ErrorType {
  android,
  c,
  cocoa,
  flutter,
}

ErrorType errorTypeByName(String? name) {
  return ErrorType.values.firstWhere(
    (element) => element.name == name,
    orElse: () => ErrorType.flutter,
  );
}
