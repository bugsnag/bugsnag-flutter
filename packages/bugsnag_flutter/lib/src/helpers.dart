import 'dart:async';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';

extension ZoneHelpers on BugsnagClient {
  /// Exactly equivalent to:
  /// ```dart
  /// return runZonedGuarded(body, bugsnag.errorHandler);
  /// ```
  R? runZoned<R>(R Function() body) => runZonedGuarded(body, errorHandler);
}
