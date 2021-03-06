# Network Breadcrumbs for Bugsnag Flutter

[http](https://pub.dev/packages/http) networking breadcrumbs for [bugsnag_flutter](https://pub.dev/packages/bugsnag_flutter).
If you are using the [HttpClient](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html) class in `dart:io` then [bugsnag_breadcrumbs_dart_io](https://pub.dev/packages/bugsnag_breadcrumbs_dart_io) should be used for networking breadcrumbs.

## Getting Started

1. Install [bugsnag_flutter](https://pub.dev/packages/bugsnag_flutter)
2. Add [bugsnag_breadcrumbs_http](https://pub.dev/packages/bugsnag_breadcrumbs_http) to your project:
```shell
flutter pub add bugsnag_breadcrumbs_http
```
3. Replace references to the `http` package with `bugsnag_breadcrumbs_http`:
```dart
import 'package:bugsnag_breadcrumbs_http/bugsnag_breadcrumbs_http.dart' as http;
```
4. Use as normal, and your network breadcrumbs will be automatically logged:
```dart
await http.get(Uri.parse('https://example.com'));
```

## License

The Bugsnag Flutter notifier is free software released under the MIT License. See
the [LICENSE](https://github.com/bugsnag/bugsnag-flutter/blob/master/LICENSE)
for details.