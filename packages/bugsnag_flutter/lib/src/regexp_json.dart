extension RegExpJSON on RegExp {
  dynamic toJson() => <String, dynamic>{
        'pattern': pattern,
        'isDotAll': isDotAll,
        'isCaseSensitive': isCaseSensitive,
        'isMultiLine': isMultiLine,
      };
}
