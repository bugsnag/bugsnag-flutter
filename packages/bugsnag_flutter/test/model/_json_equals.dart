import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

class _JsonMatcher extends CustomMatcher {
  _JsonMatcher(dynamic expectedValue)
      : super('json', 'json', equals(jsonDecode(jsonEncode(expectedValue))));

  @override
  Object? featureValueOf(actual) => jsonDecode(jsonEncode(actual));
}

Matcher jsonEquals(dynamic json) => _JsonMatcher(json);
