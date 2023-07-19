Upgrading
=========

## 2.x to 3.x

A minimum of Flutter version of 3.10.0 is now required.

### Key points

- Minimum Flutter version was bumped to 3.10.0
- `runApp` options have been removed from `start` and `attach`, instead simply `await bugsnag.start`
- `telemetry` has been made easier to control by replacing the `Set<BugsnagTelemetryType>` with a new `BugsnagTelemetryTypes`

### Starting Bugsnag

You no longer have to pass `runApp` when calling `start` and `attach`. The startup code is for a Flutter-first app is therefore:
```dart
Future<void> main() async {
   await bugsnag.start(apiKey: 'your-api-key');
   runApp(MyApplication());
}
```
or for a [native-first](https://docs.bugsnag.com/platforms/flutter/native-first-setup/) app:
```dart
Future<void> main() async {
 await bugsnag.attach(
  // configuration here
  );
  runApp(MyApplication());
}
```

Telemetry options have been simplified into a new dedicated type instead of being a set. To specify custom telemetry options, use:

```dart
bugsnag.start(
  // other options
  telemetry: const BugsnagTelemetryTypes(/* telemetry options */),
);
```

## 1.x to 2.x

Flutter is now officially supported by Bugsnag! Many thanks to the community for the [previous library](https://github.com/GetDutchie/bugsnag_flutter) and for allowing us to take the `bugsnag_flutter` package name.

To upgrade: 

* `bugsnag_flutter/bugsnag.dart` is now `bugsnag_flutter/bugsnag_flutter.dart`
*  we recommend using single Flutter project rather than separate platform projects. To continue using existing separate projects, use ternaries like `Platform.isAndroid ? androidApiKey : iosApiKey` when using `bugsnag.start`
* `.setUser` accepts a named ID instead of an unnamed ID in the first position 
* `BugsnagObserver` is now `BugsnagNavigatorObserver`
* `Bugsnag.instance` is now a global `bugsnag`
* `Bugsnag.instance.recordError` is now `bugsnag.notify`
* `Bugsnag.instance.recordFlutterError` should be translated as `bugsnag.notify(error.exception, error.stack)`
* `BugsnagBreadcrumb` is now `BreadcrumbType`
