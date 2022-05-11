import 'package:flutter/foundation.dart';

import '_model_extensions.dart';
import 'event.dart';

class BugsnagStackframe {
  BugsnagErrorType? type;
  String? file;
  int? lineNumber;
  int? columnNumber;
  String? method;
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
  String? codeIdentifier;

  BugsnagStackframe({
    this.type,
    this.file,
    this.lineNumber,
    this.columnNumber,
    this.method,
    this.inProject,
    this.frameAddress,
    this.loadAddress,
    this.isLR,
    this.isPC,
    this.symbolAddress,
    this.machoFile,
    this.machoLoadAddress,
    this.machoUUID,
    this.machoVMAddress,
    this.codeIdentifier,
  });

  BugsnagStackframe.fromJson(Map<String, Object?> json)
      : type = json.safeGet<String>('type')?.let(BugsnagErrorType.forName),
        file = json.safeGet('file'),
        lineNumber = json.safeGet<num>('lineNumber')?.toInt(),
        columnNumber = json.safeGet<num>('columnNumber')?.toInt(),
        method = json.safeGet('method'),
        inProject = json.safeGet('inProject'),
        frameAddress = _getAddress(json['frameAddress']),
        loadAddress = _getAddress(json['loadAddress']),
        isLR = json.safeGet('isLR'),
        isPC = json.safeGet('isPC'),
        symbolAddress = _getAddress(json['symbolAddress']),
        machoFile = json.safeGet('machoFile'),
        machoLoadAddress = json.safeGet('machoLoadAddress'),
        machoUUID = json.safeGet('machoUUID'),
        machoVMAddress = json.safeGet('machoVMAddress'),
        codeIdentifier = json.safeGet('codeIdentifier');

  BugsnagStackframe.fromStackFrame(StackFrame frame)
      : type = BugsnagErrorType.dart,
        file = "${frame.packageScheme}:${frame.package}/${frame.packagePath}",
        lineNumber = frame.line,
        columnNumber = frame.column,
        method = (frame.className.isNotEmpty)
            ? '${frame.className}.${frame.method}'
            : frame.method;

  dynamic toJson() => {
        if (type != null) 'type': type!.name,
        if (file != null) 'file': file,
        if (lineNumber != null) 'lineNumber': lineNumber,
        if (columnNumber != null) 'columnNumber': columnNumber,
        if (method != null) 'method': method,
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
        if (codeIdentifier != null) 'codeIdentifier': codeIdentifier,
      };

  dynamic _addressValue(String? address) {
    if (address == null) {
      return null;
    } else if (type == BugsnagErrorType.android ||
        type == BugsnagErrorType.c && address.startsWith('0x')) {
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

  static BugsnagStacktrace stacktraceFromJson(
          List<Map<String, dynamic>> json) =>
      json.map(BugsnagStackframe.fromJson).toList();
}

typedef BugsnagStacktrace = List<BugsnagStackframe>;