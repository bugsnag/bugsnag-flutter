# app

A very crashy Flutter app used for testing.

## Getting Started

### Build options
 - for Android: `flutter build apk`
 - for iOS: `flutter build ipa`

### Dart Defines

The following options can be appended to the `build` commands to customise the application
as `--dart-define`s. For example, to build an Android APK with a customised `notify` endpoint:

```shell
flutter build apk --dart-define=bsg.endpoint.notify=http://10.0.2.2:9876/notify
```

 - `bsg.endpoint.notify=http://bs-local.com:9339/notify`
 - `bsg.endpoint.session=http://bs-local.com:9339/session`
