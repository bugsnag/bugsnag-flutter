# Network Breadcrumbs for Bugsnag Flutter

HTTP networking breadcrumbs for [bugsnag-flutter](https://pub.dev/packages/bugsnag_flutter) when using the `dart:io` [HttpClient](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html).
If you are using the [http](https://pub.dev/packages/http) package then [bugsnag_breadcrumbs_http](https://pub.dev/packages/bugsnag_breadcrumbs_http) should be used for networking breadcrumbs.

## Getting Started

1. Install [bugsnag-flutter](https://pub.dev/packages/bugsnag_flutter)
2. Add [bugsnag_breadcrumbs_dart_io](https://pub.dev/packages/bugsnag_breadcrumbs_dart_io) to your project:
```shell
flutter pub add bugsnag_breadcrumbs_dart_io
```
3. Import `bugsnag_breadcrumbs_dart_io.dart` and use `BugsnagHttpClient` instead of `HttpClient`: 
```dart
import 'package:bugsnag_breadcrumbs_dart_io/bugsnag_breadcrumbs_dart_io.dart';

final httpClient = BugsnagHttpClient();
final request = await client.getUrl(Uri.parse('https://example.com'));
```

## License

The Bugsnag Flutter notifier is free software released under the MIT License. See
the [LICENSE](https://github.com/bugsnag/bugsnag-flutter/blob/master/LICENSE)
for details.