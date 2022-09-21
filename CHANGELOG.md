# Changelog

## TBD

- Update bugsnag-cocoa from v6.21.0 to [v6.23.1](https://github.com/bugsnag/bugsnag-cocoa/blob/master/CHANGELOG.md#6231-2022-09-21)
- Update bugsnag-android from v5.25.0 to [v5.26.0](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#5260-2022-08-18)

## 2.2.0 (2022-08-03)

- Added `telemetry` option to `bugsnag.start` to allow sending of internal errors to be disabled.
- Update bugsnag-android from v5.23.1 to [v5.25.0](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#5250-2022-07-19)
- Update bugsnag-cocoa from v6.18.1 to [v6.21.0](https://github.com/bugsnag/bugsnag-cocoa/blob/master/CHANGELOG.md#6210-2022-07-20)
- Fixed 'Unhandled Exception' in JSON encoding of metadata containing list objects
  [#160](https://github.com/bugsnag/bugsnag-flutter/pull/160)
- Add specific handling for 'invalid Dart instruction address' native stack frames
  [#161](https://github.com/bugsnag/bugsnag-flutter/pull/161)

## 2.1.1 (2022-06-28)

- Added `BugsnagFlutterConfiguration` to allow `bugsnag.attach` behaviour to be configured from native code.
  [#145](https://github.com/bugsnag/bugsnag-flutter/pull/145)
- Update bugsnag-android from v5.22.1 to [v5.23.1](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#5231-2022-06-23)
- Update bugsnag-cocoa from v6.16.8 to [v6.18.1](https://github.com/bugsnag/bugsnag-cocoa/blob/master/CHANGELOG.md#6181-2022-06-22)

## 2.1.0 (2022-06-14)

- Networking breadcrumbs can now be easily captured by using the `bugsnag_breadcrumbs_http` or `bugsnag_breadcrumbs_dart_io` packages
  [#116](https://github.com/bugsnag/bugsnag-flutter/pull/116) 
  [#115](https://github.com/bugsnag/bugsnag-flutter/pull/115)
- Added `BugsnagNavigatorObserver` to automatically log navigation breadcrumbs and context
- Column numbers will be captured as `null` instead of `-1` when they're not available
  [#139](https://github.com/bugsnag/bugsnag-flutter/pull/139)

## 2.0.2 (2022-05-30)

- Prefixed all class named with 'Bugsnag' to avoid clashing with application code.

## 2.0.1 (2022-05-25)

- Fixed documentation links in README.md

## 2.0.0 (2022-05-25)

First official Bugsnag release.

## 2.0.0-rc6 (2022-05-17)

First official release-candidate from Bugsnag. Completely rewritten to have tight integration with `bugsnag-cocoa`(https://github.com/bugsnag/bugsnag-cocoa) and `bugsnag-android`(https://github.com/bugsnag/bugsnag-android) and consistency of naming and behaviour with our other client libraries.

## 1.X 

[Community-created package](https://github.com/GetDutchie/bugsnag_flutter).
