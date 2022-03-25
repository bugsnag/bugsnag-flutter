import 'dart:async';

import 'package:bugsnag_flutter/bugsnag.dart';

extension ZoneHelpers on Client {
  /// Helper function
  R? runZoned<R>(R Function() body) {
    return runZonedGuarded(body, errorHandler);
  }
}
