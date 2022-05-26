Upgrading
=========

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