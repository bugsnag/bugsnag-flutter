import 'package:flutter/foundation.dart';

import '_model_extensions.dart';
import 'event.dart';

/// Represents a single stackframe from a [StackTrace]
class BugsnagStackframe {
  /// The type of the error
  BugsnagErrorType? type;

  /// The location of the source file
  String? file;

  /// The line number within the source file this stackframe refers to
  int? lineNumber;

  /// The column number of the frame
  int? columnNumber;

  /// The name of the method that was being executed
  String? method;

  /// Whether the package is considered to be in your project for the purposes
  /// of grouping and readability on the Bugsnag dashboard. Project package
  /// names can be set as `projectPackages` in [Bugsnag.start].
  bool? inProject;

  /// The address of the instruction where the event occurred.
  String? frameAddress;

  /// The address of the library where the event occurred.
  String? loadAddress;

  /// iOS only: Whether the frame was within the link register
  bool? isLR;

  /// Whether the frame was within the program counter
  bool? isPC;

  /// The address of the function where the event occurred.
  String? symbolAddress;

  /// iOS only: The Mach-O file used by the stackframe
  String? machoFile;

  /// iOS only: The load address of the Mach-O file
  String? machoLoadAddress;

  /// iOS only: A UUID identifying the Mach-O file used by the stackframe
  String? machoUUID;

  /// iOS only: The VM address of the Mach-O file
  String? machoVMAddress;

  /// Identifies the exact build this frame originates from.
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
