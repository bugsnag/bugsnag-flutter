# Bugsnag error monitoring & reporting for Flutter apps

[![Documentation](https://img.shields.io/badge/documentation-latest-blue.svg)](https://docs.bugsnag.com/platforms/flutter/)
[![Build status](https://badge.buildkite.com/e5d6c82f7202bbfe7114be8b8cb245b447a29470cd9320658b.svg?branch=main)](https://buildkite.com/bugsnag/bugsnag-flutter)

The [Bugsnag](https://www.bugsnag.com) error reporting library automatically detects Dart errors and
native crashes in Flutter apps running on iOS and Android, collecting diagnostic information and
immediately notifying your development team, helping you to understand and resolve issues as fast as
possible. Learn more about
[Flutter error monitoring with Bugsnag](https://docs.bugsnag.com/platforms/flutter/).

## Features

* Automatically report unhandled errors and crashes
* Report [handled errors](https://docs.bugsnag.com/platforms/flutter/#reporting-handled-errors)
* [Log breadcrumbs](https://docs.bugsnag.com/platforms/flutter/#logging-breadcrumbs) which are
  attached to crash reports and add insight to users' actions
* [Attach user information](https://docs.bugsnag.com/platforms/flutter/#identifying-users) to
  determine how many people are affected by an error

## Getting started

1. [Create a Bugsnag account](https://www.bugsnag.com)
1. Complete the instructions in the [integration guide](https://docs.bugsnag.com/platforms/flutter/)
   to report unhandled errors thrown from your app
1. Report handled errors
   using [`bugsnag.notify`](https://docs.bugsnag.com/platforms/flutter/reporting-handled-errors/)
1. Customize your integration using
   the [configuration options](https://docs.bugsnag.com/platforms/flutter/configuration-options/)

## Support

* [Read the integration guide](https://docs.bugsnag.com/platforms/flutter/)
  or [configuration options documentation](https://docs.bugsnag.com/platforms/flutter/configuration-options/)
* [Search open and closed issues](https://github.com/bugsnag/bugsnag-flutter/issues?utf8=✓&q=is%3Aissue)
  for similar problems
* [Report a bug or request a feature](https://github.com/bugsnag/bugsnag-flutter/issues/new)

## License

The Bugsnag Flutter notifier is free software released under the MIT License. See
the [LICENSE](https://github.com/bugsnag/bugsnag-flutter/blob/master/LICENSE)
for details.