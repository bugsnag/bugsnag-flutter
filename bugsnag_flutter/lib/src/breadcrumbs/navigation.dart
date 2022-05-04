import 'package:flutter/widgets.dart';

import '../client.dart';
import '../model.dart';

class BugsnagNavigatorObserver extends NavigatorObserver {
  final bool leaveBreadcrumbs;
  final bool setContext;
  final String _navigatorPrefix;

  /// Create and configure a `BugsnagNavigatorObserver` to listen for navigation
  /// events and leave breadcrumbs and/or set the context.
  ///
  /// If the [navigatorName] is `null` then the breadcrumbs will be prefixed
  /// with `Navigator` resulting in breadcrumbs such as `Navigator.didPush()`,
  /// `Navigator.didPop` and `Navigator.didRemove`.
  ///
  /// Typically you will configure this in you `MaterialApp`, `CupertinoApp`
  /// or `Navigator`:
  /// ```dart
  /// return MaterialApp(
  ///   navigatorObservers: [BugsnagNavigatorObserver()],
  ///   initialRoute: '/',
  ///   routes: {
  ///     '/': (context) => const AppHomeWidget(),
  /// ```
  BugsnagNavigatorObserver({
    this.leaveBreadcrumbs = true,
    this.setContext = false,
    String? navigatorName,
  }) : _navigatorPrefix =
            (navigatorName != null) ? navigatorName + '.' : 'Navigator.';

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _leaveBreadcrumb('didReplace()', {
      if (oldRoute != null) 'oldRoute': _routeToString(oldRoute),
      if (newRoute != null) 'newRoute': _routeToString(newRoute),
    });

    _updateContext(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _leaveBreadcrumb('didRemove()', {
      'route': _routeToString(route),
      if (previousRoute != null) 'previousRoute': _routeToString(previousRoute),
    });

    _updateContext(previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _leaveBreadcrumb('didPop()', {
      'route': _routeToString(route),
      if (previousRoute != null) 'previousRoute': _routeToString(previousRoute),
    });

    _updateContext(previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _leaveBreadcrumb('didPush()', {
      'route': _routeToString(route),
      if (previousRoute != null) 'previousRoute': _routeToString(previousRoute),
    });

    _updateContext(route);
  }

  void _leaveBreadcrumb(String function, Map<String, String> metadata) {
    if (leaveBreadcrumbs) {
      bugsnag.leaveBreadcrumb(
        _operationDescription(function),
        type: BreadcrumbType.navigation,
        metadata: metadata,
      );
    }
  }

  void _updateContext(Route<dynamic>? newRoute) {
    if (setContext) {
      bugsnag.setContext(newRoute != null ? _routeToString(newRoute) : null);
    }
  }

  String _routeToString(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null) return name;

    try {
      String? title = (route as dynamic).title;
      if (title != null) return title;
    } catch (_) {}

    try {
      String? debugLabel = (route as dynamic).debugLabel;
      if (debugLabel != null) return debugLabel;
    } catch (_) {}

    return route.toString();
  }

  String _operationDescription(String operation) {
    return '$_navigatorPrefix$operation';
  }
}
