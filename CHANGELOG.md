# Changelog

## TBD

### Dependencies

- Update bugsnag-cocoa to [v6.32.1](https//github.com/bugsnag/bugsnag-cocoa/releases/tag/v6.32.1) [#276](https://github.com/bugsnag/bugsnag-flutter/pull/276)

- Update bugsnag-android to [v6.12.1](https//github.com/bugsnag/bugsnag-android/releases/tag/v6.12.1) [#278](https://github.com/bugsnag/bugsnag-flutter/pull/278)

## 4.1.1 (2025-01-22)

- Update bugsnag-android from v6.6.0 to [v6.10.0](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#6100-2024-11-14)

## 4.1.0 (2024-11-04)

- Upgrade Android compileSdkVersion from 29 to 31.
  [263](https://github.com/bugsnag/bugsnag-flutter/pull/263)

## 4.0.0 (2024-07-29)

### Breaking Changes

- The configuration options `discardClasses` and `redactedKeys` are now `RegExp`s instead of strings. This allows developers to have more control over how they perform.
  [249](https://github.com/bugsnag/bugsnag-flutter/pull/249)
- Getting the correlation trace ID and span ID through `flutter_bridge` and adding it to events.
  [251](https://github.com/bugsnag/bugsnag-flutter/pull/251)
Please see our [Upgrading guide](./UPGRADING.MD) for more information on upgrading to v4.x.

## 3.1.1 (2024-04-24)

- Fixed: Navigator.pushAndRemoveUntil throws exception [#242](https://github.com/bugsnag/bugsnag-flutter/pull/242)

## 3.1.0 (2024-04-09)

This release introduces a new `networkInstrumentation` listener so that the new [http](https://pub.dev/packages/bugsnag_http_client) and [dart:io](https://pub.dev/packages/bugsnag_flutter_dart_io_http_client) wrappers can trigger network breadcrumbs. It also introduces support for [dio](https://pub.dev/packages/dio).
The previous `bugsnag_breadcrumbs_http` and `bugsnag_breadcrumbs_dart_io` packages will continue to work but will be deprecated in the next major release.
See our [online docs](https://docs.bugsnag.com/platforms/flutter/customizing-breadcrumbs/#network-request-breadcrumbs) for full integration instructions.

## 3.0.2 (2024-02-28)

- Change the bugsnag_breadcrumbs_http http dependancy to ">=0.13.4" so that there are less strict version requirements [#235](https://github.com/bugsnag/bugsnag-flutter/pull/235)
- Bundle apple xprivacy manifest with the flutter package [#230](https://github.com/bugsnag/bugsnag-flutter/pull/230)

## 3.0.1 (2024-01-11)

- Update bugsnag-cocoa from v6.26.2 to [v6.28.0](https://github.com/bugsnag/bugsnag-cocoa/blob/master/CHANGELOG.md#6280-2023-12-13)
- Update bugsnag-android from v5.30.0 to [v5.31.3](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#5313-2023-11-06)

## 3.0.0 (2023-07-19)

### Breaking Changes

- Bumped minimum Flutter version to 3.10.0
  [#203](https://github.com/bugsnag/bugsnag-flutter/pull/203)
- `runApp` options have been removed from `start` and `attach`, instead simply `await bugsnag.start`
  [#203](https://github.com/bugsnag/bugsnag-flutter/pull/203)
- `telemetry` has been made easier to control by replacing the `Set<BugsnagTelemetryType>` with a new `BugsnagTelemetryTypes`
  [#207](https://github.com/bugsnag/bugsnag-flutter/pull/207)
Please see our [Upgrading guide](./UPGRADING.MD) for more information on upgrading to v3.x.

## 2.5.0 (2023-07-17)

- Additional null safety checks in BugsnagFlutter.java [#209](https://github.com/bugsnag/bugsnag-flutter/pull/209)
- Update bugsnag-cocoa from v6.25.0 to [v6.26.2](https://github.com/bugsnag/bugsnag-cocoa/blob/master/CHANGELOG.md#6262-2023-04-20)
- Update bugsnag-android from v5.28.3 to [v5.30.0](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#5300-2023-05-11)
- Prevent crashing if the stack trace is empty
  [#204](https://github.com/bugsnag/bugsnag-flutter/pull/204)
- Include breadcrumb metadata in sanitizing (allows enums in metadata)
  [#206](https://github.com/bugsnag/bugsnag-flutter/pull/206)

## 2.4.0 (2022-12-01)

- Added `maxStringValueLength` option to `bugsnag.start` to allow truncation behaviour to be configured.
  [#179](https://github.com/bugsnag/bugsnag-flutter/pull/179)
- Native-first hot-reloads (using `bugnag.attach`) will no longer cause errors, but will instead emit a warning
  [#182](https://github.com/bugsnag/bugsnag-flutter/pull/182)
- Update bugsnag-android from v5.28.1 to [v5.28.3](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#5283-2022-11-16)

## 2.3.0 (2022-10-27)

- Added `BugsnagTelemetryType.usage` to allow sending of usage telemetry to be disabled.
  [#176](https://github.com/bugsnag/bugsnag-flutter/pull/176)
- Update bugsnag-cocoa from v6.21.0 to [v6.25.0](https://github.com/bugsnag/bugsnag-cocoa/blob/master/CHANGELOG.md#6240-2022-10-05)
- Update bugsnag-android from v5.25.0 to [v5.28.1](https://github.com/bugsnag/bugsnag-android/blob/master/CHANGELOG.md#5281-2022-10-19)

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

