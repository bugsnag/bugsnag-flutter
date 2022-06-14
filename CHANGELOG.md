# Changelog

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
