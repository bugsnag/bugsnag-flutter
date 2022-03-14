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
